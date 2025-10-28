-- Витрина данных для анализа президентов США
-- Вариант задания №16
-- Создает VIEW на основе обогащенных данных из stg_airbnb

DROP VIEW IF EXISTS airbnb_datamart;

CREATE VIEW airbnb_datamart AS
SELECT 
    neighbourhood_group,
    room_type,
    price,
    number_of_reviews,
    availability_365
FROM 
    stg_airbnb
WHERE
    -- Фильтруем данные, которые могут быть некорректными
   price > 0 ;

-- Комментарий к витрине
COMMENT ON VIEW airbnb_datamart IS 
'Обогащенная витрина данных для анализа аренды на Airbnb. Готова для использования в дашбордах.';
