# REES46 Electronics Store Customer Journey & Conversion Funnel Analysis

> **Project status:** WORK IN PROGRESS

## Project Overview

This SQL project analyses user behaviour using dataset from REES46 online electronics store to identify where customers drop off between product viewing, cart addition, and purchase.

Rather than treating every event as a separate funnel observation, the analysis groups events into session-product journeys using `user_session` and `product_id`. Funnel performance will be compared across product categories, price bands, and brands.

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

Data quality was assessed by checking row counts, exact duplicates, missing values, and key-field completeness. After removing 655 duplicated rows and excluding 162 events without valid session IDs, 884,312 event records remained available for session-based analysis. These events were grouped into 633,790 unique session-product journeys using `user_session` and `product_id`.

## Funnel Definition

Each journey represents one product within one user session.

- **Viewed:** The journey contains at least one view event
- **Carted:** The journey contains both view and cart events
- **Purchased:** The journey contains view, cart, and purchase events

Repeated events within the same journey do not count as separate funnel observations.

## Analysis Plan

The project will examine:

1. Overall conversion funnel performance
2. Conversion rates by product category
3. Conversion rates by price band
4. Conversion rates by brand

Category- and brand-level analyses are restricted to journeys with available labels. Unlabelled records remain included in the overall and price-band funnels.

## Current Progress

- [x] Data quality assessment
- [x] Exact duplicate removal
- [x] Session-product journey creation
- [x] Overall funnel structure
- [x] Initial category-level aggregation
- [x] Price-band definition
- [ ] Category conversion-rate analysis
- [ ] Price-band funnel analysis
- [ ] Brand funnel analysis
- [ ] Final findings and recommendations

## Limitations

The source dataset does not specify the currency used for product prices. Prices are therefore reported in source currency units without an assumed currency symbol.

Some product category and brand labels are missing. These records are excluded only from the corresponding segmented analysis rather than from the complete dataset.
