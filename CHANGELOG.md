# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2026-06-13

### Fixed

- QML property naming for Plasma 6 config panel compatibility (`cfg_refreshInterval`, `cfg_cookieHeader`)

## [0.3.0] - 2026-06-13

### Added

- Title "Ollama Usage" displayed at the top of the widget
- Color-coded progress bars: normal (blue/green), warning ≥80% (orange), critical ≥95% (red)
- Configuration panel (General: refresh interval + language)
- Bilingual FR/EN support (auto/system, English, French)

### Fixed

- Config panel now opens correctly (moved `config.qml` to `contents/config/`, `ConfigGeneral.qml` to `contents/ui/config/` per Plasma 6 conventions)

## [0.2.1] - 2026-05-11

### Fixed

- Regex bug: session/weekly values were identical on Pro accounts
- Backslash doubling in `extract_percent` (regex `\s` broken)
- `locale.getdefaultlocale()` DeprecationWarning
- Granular error handling in QML (python missing, script missing, invalid response, network)
- Description in metadata.json
- `.gitignore` added (.idea/, .kdev4/, *.kdev4)

### Added

- Config panel infrastructure (ConfigModel + ConfigGeneral.qml + main.xml)
- Background for widget (DefaultBackground)
- `install.sh` with checks, messages, and fallback upgrade

## [0.1.0] - 2026-05-10

### Added

- Initial release
- Session and weekly quota display (progress bars)
- Cookie extraction from Firefox and Chromium (SQLite)
- Ollama settings page scraping and parsing
- Bilingual FR/EN messages in Python backend
- Refresh button and Ollama settings link
- Auto-refresh timer (configurable interval)

[0.3.1]: https://github.com/Vbxlab/Kol-Ollama-Usage/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/Vbxlab/Kol-Ollama-Usage/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/Vbxlab/Kol/compare/v0.1.0...v0.2.1
[0.1.0]: https://github.com/Vbxlab/Kol/releases/tag/v0.1.0