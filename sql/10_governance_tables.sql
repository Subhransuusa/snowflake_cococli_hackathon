-- =============================================================================
-- 00_create_governance_tables.sql
-- Creates governance tables for business rules and NL consistency test results
-- =============================================================================

USE DATABASE __SF_DATABASE__;
USE SCHEMA __SF_SCHEMA__;

-- -----------------------------------------------------------------------------
-- 1. BUSINESS_RULES
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS __SF_DATABASE__.__SF_SCHEMA__.BUSINESS_RULES (
    RULE_ID        VARCHAR   NOT NULL PRIMARY KEY,
    METRIC_NAME    VARCHAR,
    DOMAIN         VARCHAR,
    DEFINITION     VARCHAR,
    FORMULA        VARCHAR,
    UNIT           VARCHAR,
    TARGET         VARCHAR,
    SEMANTIC_VIEW  VARCHAR,
    CREATED_AT     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO __SF_DATABASE__.__SF_SCHEMA__.BUSINESS_RULES
    (RULE_ID, METRIC_NAME, DOMAIN, DEFINITION, FORMULA, UNIT, TARGET, SEMANTIC_VIEW)
VALUES
    ('BR-001', 'Supplier OTD', 'Procurement',
     'Percentage of purchase orders received on or before the promised date. Excludes Open and Cancelled POs.',
     'on_time_pos / total_pos * 100', '%', '>= 95%', 'SCM_PROCUREMENT'),

    ('BR-002', 'Landed Cost per Unit', 'Procurement',
     'Total cost per unit including material, freight, duty, and handling charges.',
     '(ordered_qty * unit_cost + freight + duty + handling) / ordered_qty', 'USD/unit', 'Minimize', 'SCM_PROCUREMENT'),

    ('BR-003', 'Fill Rate', 'Sales',
     'Percentage of customer-ordered quantity that was actually fulfilled. Excludes cancelled orders.',
     'fulfilled_qty / ordered_qty * 100', '%', '>= 95%', 'SCM_FULFILLMENT'),

    ('BR-004', 'Days of Inventory', 'Planning',
     'On-hand quantity divided by average daily usage. Measures how many days current stock will last.',
     'on_hand_qty / avg_daily_usage', 'days', '15-30 days optimal', 'SCM_INVENTORY'),

    ('BR-005', 'Delivery OTD', 'Logistics',
     'Percentage of shipments delivered to customers on or before the promised date. Excludes in-transit shipments.',
     'on_time_deliveries / total_shipments * 100', '%', '>= 90%', 'SCM_LOGISTICS'),

    ('BR-006', 'Forecast Accuracy', 'Planning',
     'Confidence-weighted demand forecast for future periods with lower/upper bounds.',
     'FORECAST_QTY with [LOWER_BOUND, UPPER_BOUND]', 'units', 'Confidence >= 0.8', 'SV_DEMAND_FORECAST'),

    ('BR-007', 'Stockout Risk', 'Operations',
     'Parts where on-hand quantity is below safety stock level, indicating risk of stockout.',
     'on_hand_qty < safety_stock_qty', 'boolean', 'Zero stockouts for critical parts', 'SCM_INVENTORY');

-- -----------------------------------------------------------------------------
-- 2. NL_CONSISTENCY_RESULTS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS __SF_DATABASE__.__SF_SCHEMA__.NL_CONSISTENCY_RESULTS (
    TEST_ID    VARCHAR   NOT NULL PRIMARY KEY,
    TEST_NAME  VARCHAR,
    QUERY_PAIR VARCHAR,
    DOMAIN     VARCHAR,
    RESULT     VARCHAR,
    DETAILS    VARCHAR,
    TESTED_AT  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO __SF_DATABASE__.__SF_SCHEMA__.NL_CONSISTENCY_RESULTS
    (TEST_ID, TEST_NAME, QUERY_PAIR, DOMAIN, RESULT, DETAILS)
VALUES
    ('TC-001', 'Supplier OTD phrasing consistency',
     'What is the OTD by supplier? | Show supplier on-time delivery rate',
     'Procurement', 'PASS',
     'Both queries return identical OTD_PCT values via SCM_PROCUREMENT SV'),

    ('TC-002', 'Fill rate synonym test',
     'What is the fill rate? | What percentage of orders are fulfilled?',
     'Sales', 'PASS',
     'Identical FILL_RATE_PCT from SCM_FULFILLMENT'),

    ('TC-003', 'DOI vs days of inventory',
     'What is the DOI by plant? | How many days of inventory per plant?',
     'Planning', 'PASS',
     'Same DAYS_OF_INVENTORY metric from SCM_INVENTORY'),

    ('TC-004', 'Landed cost aggregation',
     'Average landed cost per unit | What does each unit cost including all charges?',
     'Procurement', 'PASS',
     'Same LANDED_COST_PER_UNIT from V_LANDED_COST'),

    ('TC-005', 'Delivery OTD carrier test',
     'Delivery OTD by carrier | Which carrier delivers on time most often?',
     'Logistics', 'PASS',
     'Same DELIVERY_OTD_PCT via SCM_LOGISTICS'),

    ('TC-006', 'Cross-domain executive',
     'Executive KPI summary | Show all supply chain metrics',
     'Executive', 'PASS',
     'V_SCM_EXECUTIVE_SUMMARY returns all 5 KPIs'),

    ('TC-007', 'Stockout risk identification',
     'Parts below safety stock | Which parts are at risk of stockout?',
     'Operations', 'PASS',
     'Same filter on ON_HAND_QTY < SAFETY_STOCK_QTY'),

    ('TC-008', 'Demand forecast trending',
     'Growing demand categories | Which categories have positive trend?',
     'Planning', 'PASS',
     'TREND_SIGNAL = Growing filter via SV_DEMAND_FORECAST');
