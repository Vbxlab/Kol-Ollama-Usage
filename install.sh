#!/usr/bin/env bash
set -euo pipefail

kpackagetool6 -t Plasma/Applet -i "$(cd "$(dirname "$0")" && pwd)"
