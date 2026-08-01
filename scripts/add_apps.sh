#!/usr/bin/env bash
set -e

SETTINGS_FILE="core/settings.py"

# Вставляем приложения перед закрывающей скобкой INSTALLED_APPS
sed -i.bak '/^INSTALLED_APPS = \[/,/^]$/ {
  /^]$/ i\
    "rest_framework",\
    "corsheaders",\
    "collects",
}' "$SETTINGS_FILE"

echo "Приложения добавлены в INSTALLED_APPS."
