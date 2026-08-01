#!/usr/bin/env bash
set -e

echo "🚀 Запуск seed_collects.sh..."

# Создаём тестовый сбор через curl (Basic Auth)
curl -s -u admin:SuperSecretPass123! \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Подарок на день рождения",
    "reason": "birthday",
    "description": "Собираем на подарок Ирине",
    "target_amount": 10000,
    "deadline": "2026-08-15T18:00:00"
  }' \
  http://127.0.0.1:8000/api/collects/ > /dev/null

COLLECT_ID=$(curl -s -u admin:SuperSecretPass123! http://127.0.0.1:8000/api/collects/ | python -c "import sys, json; data=json.load(sys.stdin); print(data['results'][0]['id'] if data.get('results') else data[0]['id'])")

echo "✅ Сбор создан, ID=$COLLECT_ID"

# Делаем два платежа
curl -s -u admin:SuperSecretPass123! \
  -H "Content-Type: application/json" \
  -d "{\"collect\": $COLLECT_ID, \"amount\": 2500}" \
  http://127.0.0.1:8000/api/payments/ > /dev/null

curl -s -u admin:SuperSecretPass123! \
  -H "Content-Type: application/json" \
  -d "{\"collect\": $COLLECT_ID, \"amount\": 1500}" \
  http://127.0.0.1:8000/api/payments/ > /dev/null

echo "✅ Платежи созданы, current_amount должен обновиться до 4000"

echo "🎉 Готово!"
