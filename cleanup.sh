#!/bin/bash

# Скрипт для полной очистки Docker-окружения проекта
# Лабораторная работа №4: Анализ стоимости аренды Airbnb (Вариант 16)

set -e

echo "🧹 Очистка Docker-окружения проекта"
echo "=================================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка прав доступа
if [ "$EUID" -ne 0 ]; then
    print_error "Этот скрипт требует sudo для выполнения операций с Docker"
    print_status "Запустите: sudo ./cleanup.sh"
    exit 1
fi

# Остановка контейнеров проекта
print_status "Остановка контейнеров проекта..."
if docker compose ps -q | grep -q .; then
    docker compose down
    print_success "Контейнеры остановлены"
else
    print_warning "Контейнеры проекта не запущены"
fi

# Удаление контейнеров проекта
print_status "Удаление контейнеров проекта..."
if docker ps -a --filter "name=Lab_4_analytical-dashboard" -q | grep -q .; then
    docker rm -f $(docker ps -a --filter "name=Lab_4_analytical-dashboard" -q) 2>/dev/null || true
    print_success "Контейнеры проекта удалены"
else
    print_warning "Контейнеры проекта не найдены"
fi

# Удаление образов проекта
print_status "Удаление образов проекта..."
if docker images --filter "reference=Lab_4_analytical-dashboard*" -q | grep -q .; then
    docker rmi -f $(docker images --filter "reference=Lab_4_analytical-dashboard*" -q) 2>/dev/null || true
    print_success "Образы проекта удалены"
else
    print_warning "Образы проекта не найдены"
fi

# Удаление кастомного образа Airflow
print_status "Удаление кастомного образа Airflow..."
if docker images --filter "reference=Lab_4_analytical-dashboard-airflow" -q | grep -q .; then
    docker rmi -f $(docker images --filter "reference=Lab_4_analytical-dashboard-airflow" -q) 2>/dev/null || true
    print_success "Кастомный образ Airflow удален"
else
    print_warning "Кастомный образ Airflow не найден"
fi

# Удаление томов проекта
print_status "Удаление томов проекта..."
if docker volume ls --filter "name=Lab_4_analytical-dashboard" -q | grep -q .; then
    docker volume rm -f $(docker volume ls --filter "name=Lab_4_analytical-dashboard" -q) 2>/dev/null || true
    print_success "Тома проекта удалены"
else
    print_warning "Тома проекта не найдены"
fi

# Удаление сетей проекта
print_status "Удаление сетей проекта..."
if docker network ls --filter "name=Lab_4_analytical-dashboard" -q | grep -q .; then
    docker network rm $(docker network ls --filter "name=Lab_4_analytical-dashboard" -q) 2>/dev/null || true
    print_success "Сети проекта удалены"
else
    print_warning "Сети проекта не найдены"
fi

# Очистка неиспользуемых ресурсов
print_status "Очистка неиспользуемых ресурсов..."
docker system prune -f
print_success "Неиспользуемые ресурсы очищены"

# Очистка неиспользуемых томов
print_status "Очистка неиспользуемых томов..."
docker volume prune -f
print_success "Неиспользуемые тома очищены"

# Очистка неиспользуемых образов
print_status "Очистка неиспользуемых образов..."
docker image prune -f
print_success "Неиспользуемые образы очищены"

# Очистка неиспользуемых сетей
print_status "Очистка неиспользуемых сетей..."
docker network prune -f
print_success "Неиспользуемые сети очищены"

echo ""
echo "✅ Очистка завершена!"
echo "=================================="
echo "Все ресурсы проекта удалены:"
echo "• Контейнеры проекта"
echo "• Образы проекта"
echo "• Тома проекта"
echo "• Сети проекта"
echo "• Неиспользуемые ресурсы Docker"
echo ""
echo "Для повторного запуска проекта выполните:"
echo "sudo docker compose up -d"
