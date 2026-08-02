# Django Task Project

Контейнеризованное Django REST API приложение с поддержкой PostgreSQL и полной локализацией на русский язык.

## Требования

- Docker
- Docker Compose

## Структура проекта

```
django-task-project4/
├── Dockerfile              # Конфигурация Docker образа
├── docker-compose.yml      # Конфигурация сервисов
├── .dockerignore          # Исключаемые файлы из образа
├── requirements.txt        # Зависимости Python
├── manage.py              # Django командная утилита
├── core/                  # Основные настройки Django
│   ├── settings.py        # Настройки приложения
│   ├── urls.py            # URL маршруты
│   └── wsgi.py            # WSGI конфигурация
├── collects/              # Приложение для сбора данных
├── payments/              # Приложение платежей
├── api/                   # REST API эндпоинты
└── README.md              # Этот файл
```

## Быстрый старт

### 1. Запуск контейнера

```bash
docker compose up --pull always
```

**Что происходит:**
- Загружается образ PostgreSQL 16
- Создается и запускается контейнер базы данных
- Строится Docker образ Django приложения
- Запускается Django сервер разработки

### 2. Проверка работы

Откройте в браузере: **http://localhost:8000**

Вы должны увидеть Django приложение.

### 3. Остановка контейнеров

Нажмите **CTRL+C** в терминале

или выполните в отдельном терминале:

```bash
docker compose down
```

## Доступные команды

### Запуск в фоне
```bash
docker compose up -d
```

### Просмотр логов
```bash
docker compose logs -f
```

### Просмотр логов конкретного сервиса
```bash
docker compose logs -f web      # Django
docker compose logs -f db       # PostgreSQL
```

### Остановка сервисов
```bash
docker compose down
```

### Удаление всех данных (включая БД)
```bash
docker compose down -v
```

### Пересборка образа
```bash
docker compose build --no-cache
docker compose up
```

## Конфигурация

### Переменные окружения

Создайте файл `.env` в корне проекта для переопределения переменных:

```env
# Django
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1

# PostgreSQL
DB_NAME=django_db
DB_USER=postgres
DB_PASSWORD=postgres

# Региональные настройки
LANG=ru_RU.UTF-8
TZ=Europe/Moscow
```

### Переменные по умолчанию

```
DEBUG: True
SECRET_KEY: django-insecure-change-me-in-production
ALLOWED_HOSTS: localhost,127.0.0.1
DB_NAME: django_db
DB_USER: postgres
DB_PASSWORD: postgres
LANG: ru_RU.UTF-8
TZ: Europe/Moscow
```

## Технические детали

### Docker образ

- **Базовый образ:** `python:3.12-alpine`
- **Размер:** ~47MB (оптимизировано с multi-stage build)
- **Локаль:** Русский (ru_RU.UTF-8)
- **Временная зона:** Europe/Moscow
- **Пользователь:** Non-root (appuser)

### Django конфигурация

- **Версия:** 6.0.7
- **Язык:** Русский (ru-ru)
- **Временная зона:** Europe/Moscow
- **Кодировка:** UTF-8
- **Аутентификация:** JWT (djangorestframework_simplejwt)
- **API фильтрация:** django-filter
- **CORS:** django-cors-headers

### PostgreSQL конфигурация

- **Версия:** 16-alpine
- **Порт:** 5432
- **Кодировка:** UTF-8
- **Временная зона:** Europe/Moscow
- **Том:** `postgres_data` (сохраняется между перезагрузками)

## Трубельшутинг

### Ошибка: "Port 8000 is already in use"

Измените порт в `docker-compose.yml`:

```yaml
ports:
  - "8001:8000"  # Внешний порт : внутренний порт
```

### Ошибка: "Port 5432 is already in use"

Измените порт PostgreSQL:

```yaml
ports:
  - "5433:5432"  # Внешний порт : внутренний порт
```

### Ошибка: "No such file or directory: manage.py"

Убедитесь, что находитесь в директории с проектом при выполнении команды.

### Чистая переустановка

```bash
# Удалить все контейнеры, образы и томы
docker compose down -v
docker system prune -a

# Запустить заново
docker compose up --pull always
```

## Файловая структура Dockerfile

```dockerfile
# Build stage - компилирование зависимостей
FROM python:3.12-alpine AS builder
  - Установка build зависимостей (gcc, musl-dev, libffi-dev, openssl-dev)
  - Компиляция Python пакетов

# Runtime stage - минимальный финальный образ
FROM python:3.12-alpine
  - Копирование только необходимых файлов из builder
  - Установка runtime зависимостей
  - Установка русской локали
  - Создание non-root пользователя
  - Запуск Django сервера
```

## Дополнительно

### Создание суперпользователя Django

```bash
docker compose exec web python manage.py createsuperuser
```

### Применение миграций

```bash
docker compose exec web python manage.py migrate
```

### Сбор статических файлов

```bash
docker compose exec web python manage.py collectstatic --noinput
```

### Запуск shell Django

```bash
docker compose exec web python manage.py shell
```

## Продакшен развертывание

Для производства используйте:

1. **Gunicorn** вместо встроенного сервера:
   ```bash
   gunicorn core.wsgi:application --bind 0.0.0.0:8000
   ```

2. **Nginx** как reverse proxy

3. **SSL/TLS** сертификаты

4. **Environment variables** для SECRET_KEY и DATABASE_URL

5. **Docker registry** для хранения образов

## Контакты и поддержка

При возникновении проблем проверьте логи:

```bash
docker compose logs -f
```

---

**Автор:** Denis Postovoytov  
**Django версия:** 6.0.7  
**Python версия:** 3.12  
**Последнее обновление:** 2026-08-02
