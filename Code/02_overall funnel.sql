-- OVERALL SESSION-PRODUCT FUNNEL

-- 1. Create session-product journeys
-- Events are grouped by user_session and product_id so repeated interactions
-- with the same product do not count as separate funnel journeys.

DROP VIEW IF EXISTS journeys;

CREATE VIEW journeys AS
SELECT
    user_session,
    product_id,

    SUM(CASE WHEN event_type = 'view'
             THEN 1 ELSE 0 END) AS view_count,

    SUM(CASE WHEN event_type = 'cart'
             THEN 1 ELSE 0 END) AS cart_count,

    SUM(CASE WHEN event_type = 'purchase'
             THEN 1 ELSE 0 END) AS purchase_count

FROM events_clean

WHERE user_session IS NOT NULL
  AND TRIM(user_session) <> ''

GROUP BY
    user_session,
    product_id;


-- 2. Examine observed journey paths
-- This identifies both the standard view-cart-purchase path and
-- non-standard paths caused by unrecorded or skipped funnel stages.

SELECT
    CASE WHEN view_count > 0
         THEN 1 ELSE 0 END AS viewed,

    CASE WHEN cart_count > 0
         THEN 1 ELSE 0 END AS carted,

    CASE WHEN purchase_count > 0
         THEN 1 ELSE 0 END AS purchased,

    COUNT(*) AS journey_count

FROM journeys

GROUP BY
    viewed,
    carted,
    purchased

ORDER BY
    viewed DESC,
    carted DESC,
    purchased DESC;


-- 3. Define and calculate conversion funnel
-- Funnel stages are cumulative: carted journeys must contain both view and
-- cart events, while purchased journeys must contain all three event types.

WITH funnel_counts AS (
    SELECT
        COUNT(*) AS total_journeys,

        SUM(CASE WHEN view_count > 0
                 THEN 1 ELSE 0 END) AS viewed_journeys,

        SUM(CASE WHEN view_count > 0
                  AND cart_count > 0
                 THEN 1 ELSE 0 END) AS carted_journeys,

        SUM(CASE WHEN view_count > 0
                  AND cart_count > 0
                  AND purchase_count > 0
                 THEN 1 ELSE 0 END) AS purchased_journeys

    FROM journeys
)

SELECT
    total_journeys,
    viewed_journeys,
    carted_journeys,
    purchased_journeys,

    ROUND(100.0 * carted_journeys / viewed_journeys, 2) AS view_to_cart_rate,

    ROUND(100.0 * purchased_journeys / carted_journeys, 2) AS cart_to_purchase_rate,

    ROUND(100.0 * purchased_journeys / viewed_journeys, 2) AS full_conversion_rate

FROM funnel_counts;