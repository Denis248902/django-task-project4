#!/usr/bin/env bash
set -e

echo "🧪 Запуск верификации бизнес-логики (Collect + Payment)..."

# 1. Получаем токен
echo "🚀 Шаг 1: Получаем JWT access-токен..."
ACCESS_TOKEN=$(curl -s -X POST "http://127.0.0.1:8000/api/auth/jwt/create/" \
  -H "Content-Type: application/json" \
  -d '{"username":"de","password":"SuperSecretPass123"}' \
  | python -c "import sys,json; data=json.load(sys.stdin); print(data['access'])")

if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Ошибка: не удалось получить токен."
  exit 1
fi
echo "✅ Токен получен (длина: ${#ACCESS_TOKEN} символов)"

# 2. Получаем ID пользователя (чище: только ID)
USER_ID=$(python manage.py shell -c "from django.contrib.auth import get_user_model; u=get_user_model().objects.get(username='de'); print(u.id)" 2>/dev/null)
echo "👤 USER_ID = $USER_ID"

# 3. Создаём тестовый сбор (JSON из файла — никаких проблем с кодировкой)
echo "📝 Шаг 2: Создаём тестовый сбор..."
COLLECT_RESPONSE=$(curl -v -X POST "http://127.0.0.1:8000/api/collects/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "@scripts/collect_payload.json")

echo "📦 Ответ сервера при создании сбора:"
echo "$COLLECT_RESPONSE" | head -n 30

# Парсим ID (если сервер вернул 201 Created с JSON)
COLLECT_ID=$(echo "$COLLECT_RESPONSE" | python -c "import sys,json; d=json.load(sys.stdin); print(d['id'])")
echo "🎉 Сбор создан, COLLECT_ID = $COLLECT_ID"

# 4. Делаем платёж (тут printf остаётся — он безопасен для чисел)
echo "💸 Шаг 3: Отправляем платёж на 500.00..."
curl -v -X POST "http://127.0.0.1:8000/api/payments/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(printf '{"collect":%d,"user":%d,"amount":"500.00"}' "$COLLECT_ID" "$USER_ID")"

# 5. Проверяем current_amount
echo "🔍 Шаг 4: Проверяем current_amount..."
CURRENT_AMOUNT=$(curl -s "http://127.0.0.1:8000/api/collects/$COLLECT_ID/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  | python -c "import sys,json; d=json.load(sys.stdin); print(d['current_amount'])")

echo "💰 Текущая сумма сбора: $CURRENT_AMOUNT"

if [ "$CURRENT_AMOUNT" = "500.00" ]; then
  echo "✅ УСПЕХ: Бизнес-логика подтверждена."
else
  echo "❌ ОШИБКА: current_amount = $CURRENT_AMOUNT (ожидалось 500.00)"
  exit 1
fi