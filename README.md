# REES46 Electronics Store Customer Journey & Conversion Funnel Analysis

> **Project status:** WORK IN PROGRESS

## Project Overview

This SQL project analyses user behaviour using an e-commerce event dataset provided by REES46 to identify where users drop off between product viewing, cart addition, and purchase.

Events are grouped into session-product journeys using user_session and product_id. This prevents repeated interactions with the same product within one session from being counted as separate funnel observations. Funnel performance will be compared across product categories, price bands, and brands.

## Repository Structure

- [`01_data quality.sql`](Code/01_data%20quality.sql) — data-quality assessment and duplicate removal
- [`02_overall funnel.sql`](Code/02_overall%20funnel.sql) — session-product journey construction and overall funnel analysis
- [`03_price band funnel.sql`](Code/03_price%20band%20funnel.sql) — conversion funnel analysis across seven price bands
- `raw data/archive.zip` — source event dataset

## Business Question

Where do users drop off in the product conversion funnel, and how does funnel performance differ across:

- Product categories
- Price bands
- Brands

## Dataset

The project uses the [eCommerce Events History in Electronics Store](https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-electronics-store) dataset published on Kaggle.

The raw dataset contains 885,129 event records and nine columns:

| Column | Description |
|---|---|
| `event_time` | Date and time when the event occurred |
| `event_type` | User action recorded as `view`, `cart`, or `purchase` |
| `product_id` | Product identifier |
| `category_id` | Product category identifier |
| `category_code` | Readable product category path, where available |
| `brand` | Product brand, where available |
| `price` | Product price in unspecified source currency units |
| `user_id` | Anonymised user identifier |
| `user_session` | Temporary user-session identifier |

## Tools

SQL, SQLite, DBeaver

## Data Preparation

Data quality check includes checking row counts, exact duplicates, missing values, and key-field completeness. After removing 655 duplicated rows and excluding 162 events without valid session IDs, 884,312 event records remained available for session-based analysis. These events were grouped into 633,790 unique session-product journeys using `user_session` and `product_id`.

## Funnel Definition

Each journey represents one product within one user session.

- **Viewed:** The journey contains at least one view event
- **Carted:** The journey contains both view and cart events
- **Purchased:** The journey contains view, cart, and purchase events

Repeated events within the same journey do not count as separate funnel observations.

## Overall Funnel Results

The analysis identified 633,790 session-product journeys. The primary funnel was defined cumulatively, with each stage requiring the preceding stages to be observed.

| Funnel stage | Journeys | Conversion from previous stage |
|---|---:|---:|
| Viewed | 631,213 | — |
| Carted | 48,977 | 7.76% |
| Purchased | 22,972 | 46.90% |

The full-funnel conversion rate was **3.64%**.

The largest observed drop-off occurred between View and Cart, with only 7.76% of viewed journeys progressing to the cart stage. Among journeys reaching the cart stage, 46.90% completed the standard purchase path.

### Non-standard Journey Paths

Of the 633,790 journeys, 4,239 (0.67%) contained non-standard event combinations. These journeys were retained in the path analysis but excluded from the cumulative standard-funnel metrics where the required intermediate stages were not observed.

## Analysis Plan

The project will examine:

1. Overall conversion funnel performance
2. Conversion rates by product category
3. Conversion rates by price band
4. Conversion rates by brand

Category- and brand-level analyses are restricted to journeys with available labels. Unlabelled records remain included in the overall and price-band funnels.

## Current Progress

- [x] Data quality check
- [x] Exact duplicate removal
- [x] Session-product journey creation
- [x] Overall funnel structure
- [x] Initial category-level aggregation
- [ ] Category conversion-rate analysis
- [x] Price-band funnel analysis
- [ ] Brand funnel analysis
- [ ] Final findings and recommendations

## Limitations

The source dataset does not specify the currency used for product prices. Prices are therefore reported in source currency units without an assumed currency symbol.

Some product category and brand labels are missing. These records are excluded only from the corresponding segmented analysis rather than from the complete dataset.
