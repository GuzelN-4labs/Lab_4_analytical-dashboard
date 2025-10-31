# Л+П №4. Разработка аналитического дашборда для бизнес-кейса 
<br>**Студент** *Нургалеева Гузель*
<br>**Вариант** *16*

## Описание проекта

Полный цикл аналитики данных для анализа стоимости аренды в Airbnb:
- Извлечение данных с Kaggle
- Загрузка в PostgreSQL
- Создание аналитической витрины
- Визуализация в Apache Superset

## Показатели

*  **neighbourhood_group (тип квартала)** - показатнль уровня квартала (уровень жизни, что может влиять на уровень безопасности и соответственно стоимости недвижимости)
*  **room_type (тип комнаты)** - может влиять на количество жильцов
*  **number_of_reviews** - количество просмотров предложения
*  **availability_365** - на какой срок можно арендовать


**Исходные данные**

*   **Kaggle Dataset**. `arianazmoudeh/airbnbopendata` — исторические данные о стоимости аренды Airbnb
*   **Поля**. 'neighbourhood_group', 'room_type', 'price', 'number_of_reviews', 'availability_365'

**Ожидаемый результат.** Интерактивный дашборд с визуализацией ключевых метрик
**Визуалы:** 
* Индикатор. Средняя price.
* Столбчатая. Средняя price по neighbourhood_group.
* Круговая. Доли по room_type.
* Комбинированная. Средняя price (столбцы) и number_of_reviews (линия) по neighbourhood_group.
* Линейная. Зависимость price от availability_365.
* Сводная таблица
* Интерактивные фильтры по room_type, neighbourhood_group

## Подробная архитектура решения

### Общая схема системы

![image](./img/schema.png)


### ETL-процесс

![image](./img/Conveyor.png)

![image](./img/conveer.jpg) 

### Подключение Airflow к PostgreSQL

**Строка подключения**: `postgresql://airflow:airflow@postgres:5432/airflow`

**Параметры подключения**:
- **Host**: postgres
- **Port**: 5432
- **Database**: airflow
- **Username**: airflow
- **Password**: airflow

### Настройка коннектора analytics_postgres

**Настройки для коннектора analytics_postgres**

| Поле в Airflow | Значение | Откуда взято (из docker-compose.yml) |
|---|---|---|
| Connection Id | analytics_postgres | Имя, используемое в DAG |
| Connection Type | Postgres | Тип базы данных |
| Host | analytics_postgres | Имя сервиса в Docker Compose |
| Schema | analytics | Из environment: POSTGRES_DB=analytics |
| Login | analytics | Из environment: POSTGRES_USER=analytics |
| Password | analytics | Из environment: POSTGRES_PASSWORD=analytics |
| Port | 5432 | Внутренний порт контейнера |

**Пошаговая инструкция**:
1. Зайдите в Airflow UI: http://localhost:8080
2. Перейдите в Admin -> Connections
3. Нажмите синюю кнопку + ("Add a new record")
4. Заполните поля формы согласно таблице выше
5. Нажмите кнопку Test (должно появиться "Connection successfully tested")
6. Нажмите Save

## Технологический стек

### Основные компоненты

*   **Apache Airflow 2.5.0** — оркестрация ETL-процессов, управление задачами
*   **PostgreSQL 12** — хранение данных и аналитическая витрина
*   **Apache Superset 3.1.1** — интерактивная визуализация и дашборды (стабильная версия)
*   **Kaggle API** — извлечение данных с платформы Kaggle
*   **pgAdmin 4** — веб-интерфейс для администрирования PostgreSQL
*   **Redis 7** — кэширование и сессии для Superset
*   **Docker & Docker Compose** — контейнеризация и оркестрация сервисов

### Python библиотеки

*   **pandas** — обработка и анализ данных
*   **kaggle** — работа с Kaggle API
*   **kagglehub** — скачивание датасетов
*   **psycopg2-binary** — подключение к PostgreSQL
*   **apache-airflow-providers-postgres** — интеграция Airflow с PostgreSQL

### Инфраструктура

*   **Кастомный Dockerfile** — образ Airflow с установленным gcc для компиляции пакетов
*   **Docker Volumes** — постоянное хранение данных
*   **Docker Networks** — изолированная сеть для сервисов


### Доступ к сервисам
- **Airflow**: http://localhost:8080 (admin/admin)
- **pgAdmin**: http://localhost:5050 (admin@admin.com/admin)
- **Superset**: http://localhost:8088 (admin/admin)

### Подключение к базе данных

1. Откройте Superset: http://localhost:8088
2. Перейдите к подключениям: Settings -> Data
3. Добавьте базу данных: Нажмите + Create Dataset
4. Заполните форму "Connect a database":

| Поле | Значение | Объяснение |
|---|---|---|
| Host | analytics_postgres | Имя сервиса базы данных в docker-compose.yml |
| Port | 5432 | Внутренний порт контейнера PostgreSQL |
| Database name | analytics | Из переменной POSTGRES_DB=analytics |
| Username | analytics | Из переменной POSTGRES_USER=analytics |
| Password | analytics | Из переменной POSTGRES_PASSWORD=analytics |
| Display Name | Analytics DB | Удобное имя для подключения |


## Структура проекта

```
lpw_04/
├── dags/
│   ├── airbnb_open_data_dag.py     # DAG для варианта 16
│   └── datamart_variant_16.sql     # SQL для витрины данных
├── docker-compose.yml              # Конфигурация инфраструктуры
├── Dockerfile                      # Кастомный образ Airflow
├── requirements.txt                # Python зависимости
├── kaggle.json                     # Kaggle API ключ
├── setup_kaggle.sh                 # Настройка Kaggle API
├── cleanup.sh                      # Очистка окружения
└── README.md                       # Документация
```

## Структура данных

### Таблица stg_airbnb
Основная таблица с обогащенными данными о президентах США:

```sql
CREATE TABLE stg_airbnb (
        neighbourhood_group TEXT,
        room_type TEXT,
        price DECIMAL(10,2),
        number_of_reviews DECIMAL(10,2),
        availability_365 DECIMAL(10,2)
    );
```

| Поле | Тип | Описание |
|---|---|---|
|neighbourhood_group| TEXT | Тип квартала |
| room_type | TEXT | тип комнаты |
| price  | DECIMAL(10,2) | цена |
| number_of_reviews | DECIMAL(10,2) | количество просмотров |
| availability_365 | DECIMAL(10,2) | срок аренды|


### Представление airbnb_datamart
VIEW на основе таблицы stg_airbnb для аналитики.

