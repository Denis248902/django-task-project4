#!/usr/bin/env bash
set -e

echo "🔑 Получаем токен..."
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"denis","password":"1"}' \
  http://127.0.0.1:8000/api/auth/jwt/create/)

ACCESS_TOKEN=$(python -c "import sys, json; data=json.loads(sys.stdin.read()); print(data['access'])" <<< "$RESPONSE")

if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Не удалось извлечь токен. Ответ сервера:"
  echo "$RESPONSE" | python -m json.tool
  exit 1
fi

echo "✅ Токен получен (первые 20 символов): ${ACCESS_TOKEN:0:20}..."

echo "📡 Делаем запрос к /api/collects/"
curl -v -H "Authorization: Bearer $ACCESS_TOKEN" \
  http://127.0.0.1:8000/api/collects/
