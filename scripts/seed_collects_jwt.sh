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

echo "📦 Создаём тестовый сбор..."
COLLECT_RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Подарок на день рождения",
    "reason": "birthday",
    "description": "Собираем на подарок Ирине",
    "target_amount": 10000,
    "deadline": "2026-08-15T18:00:00"
  }' \
  "$API_URL/api/collects/")

COLLECT_ID=$(echo "$COLLECT_RESPONSE" | python -c "import sys, json; data=json.load(sys.stdin); print(data['id'])")
echo "✅ Сбор создан, ID=$COLLECT_ID"

echo "💸 Создаём платежи..."
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"collect\": $COLLECT_ID, \"amount\": 2500}" \
  "$API_URL/api/payments/" > /dev/null

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"collect\": $COLLECT_ID, \"amount\": 1500}" \
  "$API_URL/api/payments/" > /dev/null

echo "✅ Платежи созданы."

echo "👀 Проверяем список сборов (current_amount должен быть 4000):"
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Accept: application/json" \
  "$API_URL/api/collects/"
