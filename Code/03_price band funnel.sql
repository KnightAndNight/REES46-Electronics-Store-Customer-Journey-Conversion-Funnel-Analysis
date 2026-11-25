-- PRICE BAND FUNNEL

-- Check the price range
SELECT
    MIN(price) AS lowest_price,
    MAX(price) AS highest_price
FROM events_clean;

-- Create journeys
DROP VIEW IF EXISTS journeys_with_price_band;

CREATE VIEW journeys_with_price_band AS

SELECT DISTINCT
    j.user_session,
    j.product_id,
    e.price,

    CASE
        WHEN e.price < 50 THEN '1. Under 50'
        WHEN e.price < 100 THEN '2. 50–99.99'
        WHEN e.price < 250 THEN '3. 100–249.99'
        WHEN e.price < 500 THEN '4. 250–499.99'
        WHEN e.price < 1000 THEN '5. 500–999.99'
        WHEN e.price < 2000 THEN '6. 1,000–1,999.99'
        ELSE '7. 2,000+'
    END AS price_band,

    j.view_count,
    j.cart_count,
    j.purchase_count

FROM journeys AS j

INNER JOIN events_clean AS e
    ON j.user_session = e.user_session
   AND j.product_id = e.product_id;

-- Define and calculate conversion funnel
WITH price_band_funnel AS (
		SELECT 
			price_band,
	    	SUM(CASE WHEN view_count > 0
	             	 THEN 1 ELSE 0 END) AS viewed_journeys,
	    	SUM(CASE WHEN view_count > 0
	              	  AND cart_count > 0
	      	         THEN 1 ELSE 0 END) AS carted_journeys,
	    	SUM(CASE WHEN view_count > 0
	              	  AND cart_count > 0
	              	  AND purchase_count > 0
	             	 THEN 1 ELSE 0 END) AS purchased_journeys
	FROM journeys_with_price_band
	
	GROUP BY price_band
)

-- calculate conversion rate
SELECT
	price_band,
    viewed_journeys,
    carted_journeys,
    purchased_journeys,

    ROUND(100.0 * carted_journeys / viewed_journeys, 2) AS view_to_cart_rate,

    ROUND(100.0 * purchased_journeys / carted_journeys, 2) AS cart_to_purchase_rate,

    ROUND(100.0 * purchased_journeys / viewed_journeys, 2) AS full_conversion_rate

FROM price_band_funnel

ORDER BY price_band;	
