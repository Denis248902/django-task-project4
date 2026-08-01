#!/usr/bin/env bash
set -e

API_URL="http://127.0.0.1:8000"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# Функция получения токена
get_token() {
  local username=$1
  local password=$2
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"username\":\"$username\",\"password\":\"$password\"}" \
    "${API_URL}/api/auth/jwt/create/" \
    | python -c "import sys, json; data=json.loads(sys.stdin.read()); print(data['access'])"
}

echo "🚀 Запуск тестов ролей и валидаций..."

# --- ТЕСТ 1: viewer_user — только чтение (GET) ---
TOKEN_VIEWER=$(get_token "viewer_user" "viewer123")
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN_VIEWER" "${API_URL}/api/collects/")
if [ "$RESPONSE" = "200" ]; then
  log_ok "viewer_user: GET /api/collects/ → 200 OK"
else
  log_fail "viewer_user: GET → $RESPONSE (ожидали 200)"
fi

# --- ТЕСТ 2: viewer_user — POST запрещён (403) ---
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_VIEWER" \
  -d '{"title":"Тест","reason":"birthday","target_amount":"1000.00","deadline":"2026-08-31T18:00:00Z"}' \
  "${API_URL}/api/collects/")
if [ "$RESPONSE" = "403" ]; then
  log_ok "viewer_user: POST → 403 Forbidden (правильно)"
else
  log_fail "viewer_user: POST → $RESPONSE (ожидали 403)"
fi

# --- ТЕСТ 3: editor_user — может создавать (201) ---
TOKEN_EDITOR=$(get_token "editor_user" "editor123")
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_EDITOR" \
  -d '{"title":"Сбор от редактора","reason":"birthday","target_amount":"5000.00","deadline":"2026-09-01T18:00:00Z","description":"Тест редактора"}' \
  "${API_URL}/api/collects/" \
  | grep -o '"id":' | head -n 1 || true)
if echo "$RESPONSE" | grep -q '"id"'; then
  log_ok "editor_user: POST → 201 Created (получен ID)"
else
  log_fail "editor_user: POST не вернул ID (ожидали 201)"
fi

# --- ТЕСТ 4: Валидация — неверный повод (400) ---
# reason=fake_reason — должен отклониться валидатором
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_EDITOR" \
  -d '{"title":"Плохой повод","reason":"fake_reason","target_amount":"1000.00","deadline":"2026-08-31T18:00:00Z"}' \
  "${API_URL}/api/collects/")
if [ "$RESPONSE_CODE" = "400" ]; then
  log_ok "Валидация: неверный reason → 400 Bad Request"
else
  log_fail "Валидация: неверный reason → $RESPONSE_CODE (ожидали 400)"
fi

# --- ТЕСТ 5: Валидация — отрицательная сумма (400) ---
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_EDITOR" \
  -d '{"title":"Отрицательная сумма","reason":"birthday","target_amount":-100,"deadline":"2026-08-31T18:00:00Z"}' \
  "${API_URL}/api/collects/")
if [ "$RESPONSE_CODE" = "400" ]; then
  log_ok "Валидация: target_amount < 0 → 400 Bad Request"
else
  log_fail "Валидация: target_amount < 0 → $RESPONSE_CODE (ожидали 400)"
fi

# --- ТЕСТ 6: Валидация — дедлайн в прошлом (400) ---
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_EDITOR" \
  -d '{"title":"Дедлайн в прошлом","reason":"birthday","target_amount":"1000.00","deadline":"2020-01-01T18:00:00Z"}' \
  "${API_URL}/api/collects/")
if [ "$RESPONSE_CODE" = "400" ]; then
  log_ok "Валидация: deadline в прошлом → 400 Bad Request"
else
  log_fail "Валидация: deadline в прошлом → $RESPONSE_CODE (ожидали 400)"
fi

echo ""
echo "✅ Все тесты пройдены!"
