#!/usr/bin/env python3
import configparser
import json
import locale
import os
import pathlib
import re
import shutil
import sqlite3
import sys
import tempfile
import urllib.error
import urllib.request


SETTINGS_URL = "https://ollama.com/settings"
USER_AGENT = "KOL-Plasma6-Widget/0.2"

LOGIN_MARKERS = (
    "continue with google",
    "continue with github",
    "sign in",
    "sign up",
    "teken in",
    "gaan voort",
    "create account",
)


def get_lang():
    """Return 'fr' for French locale, 'en' otherwise."""
    try:
        loc = locale.getdefaultlocale()[0] or locale.getlocale()[0] or "en"
    except Exception:
        loc = "en"
    return "fr" if loc.lower().startswith("fr") else "en"


MESSAGES = {
    "login": {
        "en": "Log in to Ollama in your browser, then refresh.",
        "fr": "Connectez-vous \u00e0 Ollama dans le navigateur, puis actualisez.",
    },
    "no_cookie": {
        "en": "No Ollama cookie found. Log in with your default browser, then refresh.",
        "fr": "Aucun cookie Ollama trouv\u00e9. Connectez-vous dans le navigateur par d\u00e9faut puis actualisez.",
    },
    "quotas_not_found": {
        "en": "Browser session detected, but Ollama quotas not found on the page.",
        "fr": "Session navigateur d\u00e9tect\u00e9e, mais quotas introuvables sur la page Ollama.",
    },
    "http_error": {
        "en": "Ollama responded with HTTP {code}.",
        "fr": "Ollama a r\u00e9pondu avec HTTP {code}.",
    },
    "fetch_error": {
        "en": "Cannot contact Ollama: {error}",
        "fr": "Impossible de contacter Ollama : {error}",
    },
}


def msg(key, **kwargs):
    lang = get_lang()
    template = MESSAGES.get(key, {}).get(lang, MESSAGES.get(key, {}).get("en", key))
    return template.format(**kwargs)


def print_json(payload):
    sys.stdout.write(json.dumps(payload, ensure_ascii=True))


def read_sqlite_rows(database_path, query):
    with tempfile.TemporaryDirectory(prefix="kol-ollama-") as temp_dir:
        temp_db = pathlib.Path(temp_dir) / "cookies.sqlite"
        shutil.copy2(database_path, temp_db)
        for suffix in ("-wal", "-shm"):
            sidecar = pathlib.Path(str(database_path) + suffix)
            if sidecar.exists():
                shutil.copy2(sidecar, pathlib.Path(str(temp_db) + suffix))
        connection = sqlite3.connect(temp_db)
        try:
            cursor = connection.execute(query)
            return cursor.fetchall()
        finally:
            connection.close()


def find_firefox_profiles():
    profiles = []
    roots = [
        pathlib.Path.home() / ".mozilla" / "firefox",
        pathlib.Path.home() / ".config" / "mozilla" / "firefox",
        pathlib.Path.home() / "snap" / "firefox" / "common" / ".mozilla" / "firefox",
        pathlib.Path.home() / ".var" / "app" / "org.mozilla.firefox" / ".mozilla" / "firefox",
    ]

    for root in roots:
        profiles_ini = root / "profiles.ini"
        if not profiles_ini.exists():
            continue

        parser = configparser.RawConfigParser()
        parser.read(profiles_ini)

        for section in parser.sections():
            if not section.startswith("Profile"):
                continue

            path_value = parser.get(section, "Path", fallback="")
            if not path_value:
                continue

            is_relative = parser.getint(section, "IsRelative", fallback=1)
            default = parser.getint(section, "Default", fallback=0) == 1
            path = pathlib.Path(path_value)
            if is_relative:
                path = profiles_ini.parent / path

            profiles.append((default, path))

    profiles.sort(key=lambda item: item[0], reverse=True)
    return [path for _, path in profiles]


def firefox_cookie_header():
    for profile in find_firefox_profiles():
        cookie_db = profile / "cookies.sqlite"
        if not cookie_db.exists():
            continue

        rows = read_sqlite_rows(
            cookie_db,
            """
            SELECT name, value
            FROM moz_cookies
            WHERE host LIKE '%ollama.com'
            ORDER BY host DESC, path DESC
            """,
        )
        cookies = [f"{name}={value}" for name, value in rows if value]
        if cookies:
            return "; ".join(cookies)

    return ""


def chromium_cookie_header():
    roots = [
        pathlib.Path.home() / ".config" / "google-chrome",
        pathlib.Path.home() / ".config" / "chromium",
        pathlib.Path.home() / ".config" / "BraveSoftware" / "Brave-Browser",
        pathlib.Path.home() / ".config" / "vivaldi",
    ]

    for root in roots:
        if not root.exists():
            continue

        profiles = [root / "Default"] + sorted(root.glob("Profile *"))
        for profile in profiles:
            cookie_db = profile / "Cookies"
            if not cookie_db.exists():
                continue

            rows = read_sqlite_rows(
                cookie_db,
                """
                SELECT name, value
                FROM cookies
                WHERE host_key LIKE '%ollama.com'
                ORDER BY host_key DESC, path DESC
                """,
            )
            cookies = [f"{name}={value}" for name, value in rows if value]
            if cookies:
                return "; ".join(cookies)

    return ""


def cookie_header():
    manual_cookie = os.environ.get("OLLAMA_COOKIE_HEADER", "").strip()
    if manual_cookie:
        return manual_cookie

    return firefox_cookie_header() or chromium_cookie_header()


def fetch_settings(cookie_value):
    request = urllib.request.Request(
        SETTINGS_URL,
        headers={
            "Cookie": cookie_value,
            "User-Agent": USER_AGENT,
            "Accept": "text/html,application/xhtml+xml",
        },
    )

    with urllib.request.urlopen(request, timeout=20) as response:
        return response.read().decode("utf-8", errors="replace")


def compact_text(html):
    without_scripts = re.sub(r"<script.*?</script>", " ", html, flags=re.I | re.S)
    without_styles = re.sub(r"<style.*?</style>", " ", without_scripts, flags=re.I | re.S)
    without_tags = re.sub(r"<[^>]+>", " ", without_styles)
    return re.sub(r"\s+", " ", without_tags).strip()


def extract_percent(label, html_text):
    match = re.search(rf"{label}[^%]{{0,160}}?(\d+(?:[.,]\d+)?)\s*%", html_text, flags=re.I)
    if not match:
        return None

    return float(match.group(1).replace(",", "."))


def parse_usage(html):
    lower_html = html.lower()
    plain_text = compact_text(html)
    lower_text = plain_text.lower()

    if any(marker in lower_text for marker in LOGIN_MARKERS):
        return {
            "status": "login",
            "message": msg("login"),
        }

    session_value = extract_percent("session", lower_html)
    if session_value is None:
        session_value = extract_percent("session", lower_text)

    weekly_value = extract_percent("weekly", lower_html)
    if weekly_value is None:
        weekly_value = extract_percent("weekly", lower_text)

    if session_value is None or weekly_value is None:
        return {
            "status": "error",
            "message": msg("quotas_not_found"),
        }

    return {
        "status": "ok",
        "session": {"value": max(0.0, min(100.0, session_value))},
        "weekly": {"value": max(0.0, min(100.0, weekly_value))},
    }


def main():
    cookies = cookie_header()
    if not cookies:
        print_json(
            {
                "status": "login",
                "message": msg("no_cookie"),
            }
        )
        return 0

    try:
        html = fetch_settings(cookies)
    except urllib.error.HTTPError as error:
        print_json(
            {
                "status": "error",
                "message": msg("http_error", code=error.code),
            }
        )
        return 0
    except Exception as error:
        print_json(
            {
                "status": "error",
                "message": msg("fetch_error", error=error),
            }
        )
        return 0

    print_json(parse_usage(html))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())