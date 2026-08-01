#!/usr/bin/env bash
set -e

API_URL="http://127.0.0.1:8000"
USERNAME="denis"
PASSWORD="1"

echo "🚀 Получаем JWT access‑токен..."
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" \
  "$API_URL/api/token/")

ACCESS_TOKEN=$(echo "$RESPONSE" | python -c "import sys, json; data=json.load(sys.stdin); print(data['access'])")

if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Ошибка: не удалось получить токен. Проверь логин/пароль."
  exit 1
fi
echo "✅ Токен получен."

echo "📡 Делаем запрос к /api/collects/..."
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Accept: application/json" \
     "$API_URL/api/collects/"
