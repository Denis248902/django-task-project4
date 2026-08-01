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
  echo "❌ Ошибка: не удалось получить токен."
  exit 1
fi
echo "✅ Токен получен."

check_endpoint() {
  local endpoint="$1"
  local label="$2"
  echo "🧪 $label:"
  curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Accept: application/json" \
    "$endpoint" \
    | python -m json.tool
}

check_endpoint "$API_URL/api/collects/" "Пагинация (список)"
check_endpoint "$API_URL/api/collects/?reason=birthday" "Фильтр: reason=birthday"
check_endpoint "$API_URL/api/collects/?search=подарок" "Поиск: search=подарок"
check_endpoint "$API_URL/api/collects/?ordering=deadline" "Сортировка: ordering=deadline"

echo "✅ Все проверки завершены."
