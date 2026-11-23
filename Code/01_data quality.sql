-- CHECK DATA QUALITY AND CLEANING

-- 1. Inspect the table schema

PRAGMA table_info(events);


-- 2. Count raw event records

SELECT
    COUNT(*) AS raw_event_count
FROM events;


-- 3. Check duplicate records

WITH duplicate_groups AS (
    SELECT
        event_time,
        event_type,
        product_id,
        category_id,
        category_code,
        brand,
        price,
        user_id,
        user_session,
        COUNT(*) AS row_count
    FROM events
    GROUP BY
        event_time,
        event_type,
        product_id,
        category_id,
        category_code,
        brand,
        price,
        user_id,
        user_session
    HAVING COUNT(*) > 1
)

SELECT
    COUNT(*) AS duplicate_group_count,
    SUM(row_count - 1) AS extra_duplicate_rows
FROM duplicate_groups;


-- 4. Create a cleaned view with distinct records

-- only remove exact duplicate records while preserving legitimate
-- repeated actions, such as multiple views of the same product.

DROP VIEW IF EXISTS events_clean;

CREATE VIEW events_clean AS
SELECT DISTINCT
    event_time,
    event_type,
    product_id,
    category_id,
    category_code,
    brand,
    price,
    user_id,
    user_session
FROM events;


-- 5. Check completeness

SELECT
    COUNT(*) AS cleaned_event_count
FROM events_clean;

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN event_time IS NULL
                  OR TRIM(event_time) = ''
             THEN 1 ELSE 0 END) AS missing_event_time,

    SUM(CASE WHEN event_type IS NULL
                  OR TRIM(event_type) = ''
             THEN 1 ELSE 0 END) AS missing_event_type,

    SUM(CASE WHEN product_id IS NULL
             THEN 1 ELSE 0 END) AS missing_product_id,

    SUM(CASE WHEN category_id IS NULL
             THEN 1 ELSE 0 END) AS missing_category_id,

    SUM(CASE WHEN category_code IS NULL
                  OR TRIM(category_code) = ''
             THEN 1 ELSE 0 END) AS missing_category_code,

    SUM(CASE WHEN brand IS NULL
                  OR TRIM(brand) = ''
             THEN 1 ELSE 0 END) AS missing_brand,

    SUM(CASE WHEN price IS NULL
             THEN 1 ELSE 0 END) AS missing_price,

    SUM(CASE WHEN user_id IS NULL
             THEN 1 ELSE 0 END) AS missing_user_id,

    SUM(CASE WHEN user_session IS NULL
                  OR TRIM(user_session) = ''
             THEN 1 ELSE 0 END) AS missing_user_session

FROM events_clean;