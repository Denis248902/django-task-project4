#!/usr/bin/env bash
set -e

echo "🔑 Получаем JWT‑токен..."
ACCESS_TOKEN=$(curl -s -X POST "http://127.0.0.1:8000/api/auth/jwt/create/" \
  -H "Content-Type: application/json" \
  -d '{"username":"de","password":"SuperSecretPass123"}' \
  | python -c "import sys,json; data=json.load(sys.stdin); print(data['access'])")

if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Ошибка: не удалось получить токен"
  exit 1
fi

echo "✅ Токен получен. Создаём тестовые данные..."

# Сбор 1: с лимитом
echo "📝 Создаём сбор #1 (с лимитом)..."
COLLECT_1=$(curl -s -X POST "http://127.0.0.1:8000/api/collects/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary '{"title":"Подарок на ДР","reason":"gift","description":"Общий подарок","target_amount":"5000.00","deadline":"2026-12-31T23:59:59Z"}' \
  | python -c "import sys,json; print(json.load(sys.stdin)['id'])")
curl -s -X POST "http://127.0.0.1:8000/api/payments/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "{\"collect\": $COLLECT_1, \"amount\": \"500.00\"}"

# Сбор 2: без лимита
echo "📝 Создаём сбор #2 (без лимита)..."
COLLECT_2=$(curl -s -X POST "http://127.0.0.1:8000/api/collects/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary '{"title":"Сбор без лимита","reason":"other","description":"Просто собираем сколько получится","deadline":"2026-12-31T23:59:59Z"}' \
  | python -c "import sys,json; print(json.load(sys.stdin)['id'])")
curl -s -X POST "http://127.0.0.1:8000/api/payments/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "{\"collect\": $COLLECT_2, \"amount\": \"200.00\"}"
curl -s -X POST "http://127.0.0.1:8000/api/payments/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "{\"collect\": $COLLECT_2, \"amount\": \"300.00\"}"

# Сбор 3: ещё один с лимитом
echo "📝 Создаём сбор #3 (с лимитом)..."
COLLECT_3=$(curl -s -X POST "http://127.0.0.1:8000/api/collects/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary '{"title":"Свадьба","reason":"wedding","description":"Подарок на свадьбу","target_amount":"10000.00","deadline":"2026-12-31T23:59:59Z"}' \
  | python -c "import sys,json; print(json.load(sys.stdin)['id'])")
curl -s -X POST "http://127.0.0.1:8000/api/payments/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "{\"collect\": $COLLECT_3, \"amount\": \"1000.00\"}"

echo "🎉 Готово! Создано 3 сбора и 4 платежа."
