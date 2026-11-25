-- PRODUCT CATEGORY FUNNEL

-- Check the number of available categories
SELECT
    COUNT(DISTINCT category_code) AS category_count

FROM events_clean

WHERE category_code IS NOT NULL
  AND TRIM(category_code) <> '';


-- Add product category to each journey
DROP VIEW IF EXISTS journeys_with_category;

CREATE VIEW journeys_with_category AS

SELECT DISTINCT
    j.user_session,
    j.product_id,
    e.category_code,
    j.view_count,
    j.cart_count,
    j.purchase_count

FROM journeys AS j

INNER JOIN events_clean AS e
    ON j.user_session = e.user_session
   AND j.product_id = e.product_id

WHERE e.category_code IS NOT NULL
  AND TRIM(e.category_code) <> '';


-- Define and calculate category funnel
DROP VIEW IF EXISTS category_funnel;

CREATE VIEW category_funnel AS

WITH category_funnel_counts AS (
    SELECT
        category_code,

        SUM(CASE WHEN view_count > 0
                 THEN 1 ELSE 0 END) AS viewed_journeys,

        SUM(CASE WHEN view_count > 0
                  AND cart_count > 0
                 THEN 1 ELSE 0 END) AS carted_journeys,

        SUM(CASE WHEN view_count > 0
                  AND cart_count > 0
                  AND purchase_count > 0
                 THEN 1 ELSE 0 END) AS purchased_journeys

    FROM journeys_with_category

    GROUP BY category_code
)

SELECT
    category_code,
    viewed_journeys,
    carted_journeys,
    purchased_journeys,

    ROUND(100.0 * carted_journeys / viewed_journeys, 2) AS view_to_cart_rate,

    ROUND(100.0 * purchased_journeys / carted_journeys, 2) AS cart_to_purchase_rate,

    ROUND(100.0 * purchased_journeys / viewed_journeys, 2) AS full_conversion_rate

FROM category_funnel_counts;


-- Check category sizes before ranking
SELECT *
FROM category_funnel

ORDER BY viewed_journeys DESC;


-- Top 10 categories by full conversion rate
-- Categories with fewer than 100 viewed journeys are excluded
-- to avoid rankings based on extremely small samples
SELECT *
FROM category_funnel

WHERE viewed_journeys >= 100

ORDER BY full_conversion_rate DESC

LIMIT 10;


-- Bottom 10 categories by full conversion rate
-- The same criteria for sample is used
SELECT *
FROM category_funnel

WHERE viewed_journeys >= 100

ORDER BY full_conversion_rate ASC

LIMIT 10;
