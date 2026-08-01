#!/usr/bin/env bash
set -e

FILE="collects/viewsets.py"

if [ ! -f "$FILE" ]; then
  echo "❌ Файл $FILE не найден!"
  exit 1
fi

echo "🔧 Правлю $FILE..."

# 1. Добавляем импорт, если его ещё нет
if ! grep -q "from api.permissions import IsEditorOrReadOnly" "$FILE"; then
  # Вставляем импорт сразу после блока импортов rest_framework (это самый безопасный вариант)
  sed -i '/from rest_framework import viewsets/a\from api.permissions import IsEditorOrReadOnly' "$FILE"
fi

# 2. Добавляем permission_classes в класс CollectViewSet, если нет
if ! grep -q "permission_classes = \[IsEditorOrReadOnly\]" "$FILE"; then
  sed -i "/class CollectViewSet(viewsets.ModelViewSet):/a \    permission_classes = [IsEditorOrReadOnly]" "$FILE"
fi

echo "✅ Готово: $FILE обновлён."
