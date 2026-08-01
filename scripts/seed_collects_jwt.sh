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

# Создаём JSON‑файл с данными (чтобы не ломать кавычки в Bash)
TMP_DATA=$(mktemp)
cat > "$TMP_DATA" << 'JSON_DATA'
{
  "title": "Подарок на день рождения",
  "reason": "birthday",
  "description": "Собираем на подарок Ирине",
  "target_amount": 10000,
  "deadline": "2026-08-15T18:00:00"
}
JSON_DATA

echo "📦 Создаём тестовый сбор..."
COLLECT_RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "@$TMP_DATA" \
  "$API_URL/api/collects/")

# Удаляем временный файл
rm -f "$TMP_DATA"

# Пытаемся вытащить ID, но сначала проверяем, нет ли ошибки
if echo "$COLLECT_RESPONSE" | grep -q '"detail"'; then
  echo "❌ Ошибка при создании сбора. Ответ сервера:"
  echo "$COLLECT_RESPONSE"
  exit 1
fi

COLLECT_ID=$(echo "$COLLECT_RESPONSE" | python -c "import sys, json; data=json.load(sys.stdin); print(data.get('id'))")

if [ -z "$COLLECT_ID" ]; then
  echo "❌ Не удалось получить ID сбора. Полный ответ:"
  echo "$COLLECT_RESPONSE"
  exit 1
fi

echo "✅ Сбор создан, ID=$COLLECT_ID"

# Платежи
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

echo "👀 Проверяем список сборов:"
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Accept: application/json" \
  "$API_URL/api/collects/"
