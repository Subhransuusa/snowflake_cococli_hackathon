-- ============================================================
-- Supply Chain Ontology - Semantic Views Deployment
-- Target: __SF_DATABASE__.__SF_SCHEMA__
-- Canonical Metrics: OTD, Fill Rate, Days of Inventory, Landed Cost
-- Each semantic view includes embedded Verified Queries (VQRs)
-- ============================================================

USE DATABASE __SF_DATABASE__;
USE SCHEMA __SF_SCHEMA__;

-- ============================================================
-- Semantic View: SCM_PROCUREMENT (Procurement: Supplier OTD + Landed Cost)
-- ============================================================

CREATE OR REPLACE SEMANTIC VIEW __SF_DATABASE__.__SF_SCHEMA__.SCM_PROCUREMENT
  AS 'name: SCM_PROCUREMENT
description: Procurement analytics for supply chain management. Covers supplier performance
  metrics including On-Time Delivery (OTD) rate and Landed Cost analysis across suppliers,
  parts, and plants. Used by procurement and planning personas to evaluate supplier
  reliability, cost efficiency, and lead time compliance.
tables:
  - name: SUPPLIERS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: SUPPLIERS
    primary_key:
      columns:
        - SUPPLIER_ID
    dimensions:
      - name: SUPPLIER_ID
        expr: SUPPLIER_ID
        data_type: VARCHAR
      - name: SUPPLIER_NAME
        expr: SUPPLIER_NAME
        data_type: VARCHAR
      - name: COUNTRY
        expr: COUNTRY
        data_type: VARCHAR
      - name: REGION
        expr: REGION
        data_type: VARCHAR
      - name: TIER
        expr: TIER
        data_type: NUMBER
      - name: LEAD_TIME_DAYS
        expr: LEAD_TIME_DAYS
        data_type: NUMBER
      - name: ACTIVE
        expr: ACTIVE
        data_type: BOOLEAN
    facts:
      - name: RELIABILITY_SCORE
        expr: RELIABILITY_SCORE
        data_type: NUMBER
  - name: PARTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PARTS
    primary_key:
      columns:
        - PART_ID
    dimensions:
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: PART_NAME
        expr: PART_NAME
        data_type: VARCHAR
      - name: CATEGORY
        expr: CATEGORY
        data_type: VARCHAR
      - name: SUBCATEGORY
        expr: SUBCATEGORY
        data_type: VARCHAR
      - name: UNIT_OF_MEASURE
        expr: UNIT_OF_MEASURE
        data_type: VARCHAR
      - name: CRITICAL_FLAG
        expr: CRITICAL_FLAG
        data_type: BOOLEAN
    facts:
      - name: STANDARD_COST
        expr: STANDARD_COST
        data_type: NUMBER
      - name: WEIGHT_KG
        expr: WEIGHT_KG
        data_type: NUMBER
  - name: PLANTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PLANTS
    primary_key:
      columns:
        - PLANT_ID
    dimensions:
      - name: PLANT_ID
        expr: PLANT_ID
        data_type: VARCHAR
      - name: PLANT_NAME
        expr: PLANT_NAME
        data_type: VARCHAR
      - name: CITY
        expr: CITY
        data_type: VARCHAR
      - name: COUNTRY
        expr: COUNTRY
        data_type: VARCHAR
      - name: REGION
        expr: REGION
        data_type: VARCHAR
      - name: PLANT_TYPE
        expr: PLANT_TYPE
        data_type: VARCHAR
      - name: CAPACITY_UNITS
        expr: CAPACITY_UNITS
        data_type: NUMBER
  - name: SUPPLIER_PARTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: SUPPLIER_PARTS
    primary_key:
      columns:
        - SUPPLIER_ID
        - PART_ID
    foreign_keys:
      - fkey_columns:
          - PART_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PARTS
        pkey_columns:
          - PART_ID
      - fkey_columns:
          - SUPPLIER_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: SUPPLIERS
        pkey_columns:
          - SUPPLIER_ID
    dimensions:
      - name: SUPPLIER_ID
        expr: SUPPLIER_ID
        data_type: VARCHAR
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: MIN_ORDER_QTY
        expr: MIN_ORDER_QTY
        data_type: NUMBER
      - name: LEAD_TIME_DAYS
        expr: LEAD_TIME_DAYS
        data_type: NUMBER
    time_dimensions:
      - name: CONTRACT_START
        expr: CONTRACT_START
        data_type: DATE
      - name: CONTRACT_END
        expr: CONTRACT_END
        data_type: DATE
    facts:
      - name: UNIT_PRICE
        expr: UNIT_PRICE
        data_type: NUMBER
  - name: PURCHASE_ORDERS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PURCHASE_ORDERS
    primary_key:
      columns:
        - PO_ID
    foreign_keys:
      - fkey_columns:
          - PART_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PARTS
        pkey_columns:
          - PART_ID
      - fkey_columns:
          - PLANT_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PLANTS
        pkey_columns:
          - PLANT_ID
      - fkey_columns:
          - SUPPLIER_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: SUPPLIERS
        pkey_columns:
          - SUPPLIER_ID
    dimensions:
      - name: PO_ID
        expr: PO_ID
        data_type: VARCHAR
      - name: SUPPLIER_ID
        expr: SUPPLIER_ID
        data_type: VARCHAR
      - name: PLANT_ID
        expr: PLANT_ID
        data_type: VARCHAR
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: ORDERED_QTY
        expr: ORDERED_QTY
        data_type: NUMBER
      - name: RECEIVED_QTY
        expr: RECEIVED_QTY
        data_type: NUMBER
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
    time_dimensions:
      - name: ORDER_DATE
        expr: ORDER_DATE
        data_type: DATE
      - name: PROMISED_DATE
        expr: PROMISED_DATE
        data_type: DATE
      - name: RECEIVED_DATE
        expr: RECEIVED_DATE
        data_type: DATE
    facts:
      - name: UNIT_COST
        expr: UNIT_COST
        data_type: NUMBER
      - name: FREIGHT_COST
        expr: FREIGHT_COST
        data_type: NUMBER
      - name: DUTY_COST
        expr: DUTY_COST
        data_type: NUMBER
      - name: HANDLING_COST
        expr: HANDLING_COST
        data_type: NUMBER
relationships:
  - name: PURCHASE_ORDERS_TO_PARTS
    left_table: PURCHASE_ORDERS
    right_table: PARTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PART_ID
        right_column: PART_ID
  - name: PURCHASE_ORDERS_TO_PLANTS
    left_table: PURCHASE_ORDERS
    right_table: PLANTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PLANT_ID
        right_column: PLANT_ID
  - name: PURCHASE_ORDERS_TO_SUPPLIERS
    left_table: PURCHASE_ORDERS
    right_table: SUPPLIERS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: SUPPLIER_ID
        right_column: SUPPLIER_ID
  - name: SUPPLIER_PARTS_TO_PARTS
    left_table: SUPPLIER_PARTS
    right_table: PARTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PART_ID
        right_column: PART_ID
  - name: SUPPLIER_PARTS_TO_SUPPLIERS
    left_table: SUPPLIER_PARTS
    right_table: SUPPLIERS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: SUPPLIER_ID
        right_column: SUPPLIER_ID
verified_queries:
  - name: 0;1
    question: What is the on-time delivery rate by supplier and month?
    sql: SELECT s.SUPPLIER_NAME, s.REGION, DATE_TRUNC(''MONTH'', po.ORDER_DATE) AS order_month,
      COUNT(*) AS total_pos, SUM(CASE WHEN po.STATUS = ''Received'' AND po.RECEIVED_DATE
      <= po.PROMISED_DATE THEN 1 ELSE 0 END) AS on_time_pos, ROUND(on_time_pos * 100.0
      / NULLIF(total_pos, 0), 2) AS otd_pct FROM purchase_orders AS po JOIN suppliers
      AS s ON po.SUPPLIER_ID = s.SUPPLIER_ID WHERE NOT po.STATUS IN (''Open'', ''Cancelled'')
      GROUP BY 1, 2, 3 ORDER BY 3 DESC, 6
    verified_at: 1789210169
    verified_by: Semantic Model Generator
  - name: 1;1
    question: What are the top 20 purchase orders by total landed cost?
    sql: SELECT s.SUPPLIER_NAME, pt.PART_NAME, pl.PLANT_NAME, po.ORDER_DATE, po.ORDERED_QTY,
      po.UNIT_COST, (po.ORDERED_QTY * po.UNIT_COST) AS material_cost, po.FREIGHT_COST,
      po.DUTY_COST, po.HANDLING_COST, (po.ORDERED_QTY * po.UNIT_COST) + po.FREIGHT_COST
      + po.DUTY_COST + po.HANDLING_COST AS total_landed_cost, ROUND(((po.ORDERED_QTY
      * po.UNIT_COST) + po.FREIGHT_COST + po.DUTY_COST + po.HANDLING_COST) / NULLIF(po.ORDERED_QTY,
      0), 2) AS landed_cost_per_unit FROM purchase_orders AS po JOIN suppliers AS
      s ON po.SUPPLIER_ID = s.SUPPLIER_ID JOIN parts AS pt ON po.PART_ID = pt.PART_ID
      JOIN plants AS pl ON po.PLANT_ID = pl.PLANT_ID WHERE po.STATUS <> ''Cancelled''
      ORDER BY total_landed_cost DESC LIMIT 20
    verified_at: 1789210169
    verified_by: Semantic Model Generator
  - name: 2;1
    question: What is the average actual lead time vs contracted lead time by supplier?
    sql: SELECT s.SUPPLIER_NAME, s.TIER, ROUND(AVG(DATEDIFF(DAY, po.ORDER_DATE, po.RECEIVED_DATE)),
      1) AS avg_actual_lead_time, s.LEAD_TIME_DAYS AS contracted_lead_time, COUNT(*)
      AS total_orders FROM purchase_orders AS po JOIN suppliers AS s ON po.SUPPLIER_ID
      = s.SUPPLIER_ID WHERE po.STATUS = ''Received'' GROUP BY 1, 2, 4 ORDER BY 3 DESC
    verified_at: 1789210169
    verified_by: Semantic Model Generator
  - name: 3;1
    question: What is the average landed cost per unit by supplier region and month?
    sql: SELECT s.REGION AS supplier_region, DATE_TRUNC(''MONTH'', po.ORDER_DATE) AS
      order_month, ROUND(AVG(((po.ORDERED_QTY * po.UNIT_COST) + po.FREIGHT_COST +
      po.DUTY_COST + po.HANDLING_COST) / NULLIF(po.ORDERED_QTY, 0)), 2) AS avg_landed_cost_per_unit
      FROM purchase_orders AS po JOIN suppliers AS s ON po.SUPPLIER_ID = s.SUPPLIER_ID
      WHERE po.STATUS <> ''Cancelled'' GROUP BY 1, 2 ORDER BY 2, 1
    verified_at: 1789210169
    verified_by: Semantic Model Generator
  - name: 4;1
    question: Which suppliers have the best on-time delivery performance and what
      is their average landed cost per unit?
    sql: SELECT s.SUPPLIER_NAME, s.TIER, COUNT(*) AS total_pos, SUM(CASE WHEN po.STATUS
      = ''Received'' AND po.RECEIVED_DATE <= po.PROMISED_DATE THEN 1 ELSE 0 END) AS
      on_time, ROUND(on_time * 100.0 / total_pos, 2) AS otd_pct, ROUND(AVG(((po.ORDERED_QTY
      * po.UNIT_COST) + po.FREIGHT_COST + po.DUTY_COST + po.HANDLING_COST) / NULLIF(po.ORDERED_QTY,
      0)), 2) AS avg_landed_cost FROM purchase_orders AS po JOIN suppliers AS s ON
      po.SUPPLIER_ID = s.SUPPLIER_ID WHERE NOT po.STATUS IN (''Open'', ''Cancelled'')
      GROUP BY 1, 2 ORDER BY otd_pct DESC
    verified_at: 1789210169
    verified_by: Semantic Model Generator';

-- ============================================================
-- Semantic View: SCM_INVENTORY (Inventory: Days of Inventory)
-- ============================================================

CREATE OR REPLACE SEMANTIC VIEW __SF_DATABASE__.__SF_SCHEMA__.SCM_INVENTORY
  AS 'name: SCM_INVENTORY
description: Inventory analytics for supply chain planning. Tracks Days of Inventory
  (DOI), safety stock coverage, and reorder status across plants and parts. Used by
  planning and operations personas to monitor inventory health, identify stockout
  risks, and optimize working capital.
tables:
  - name: PLANTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PLANTS
    primary_key:
      columns:
        - PLANT_ID
    dimensions:
      - name: PLANT_ID
        expr: PLANT_ID
        data_type: VARCHAR
      - name: PLANT_NAME
        expr: PLANT_NAME
        data_type: VARCHAR
      - name: CITY
        expr: CITY
        data_type: VARCHAR
      - name: COUNTRY
        expr: COUNTRY
        data_type: VARCHAR
      - name: REGION
        expr: REGION
        data_type: VARCHAR
      - name: PLANT_TYPE
        expr: PLANT_TYPE
        data_type: VARCHAR
      - name: CAPACITY_UNITS
        expr: CAPACITY_UNITS
        data_type: NUMBER
  - name: PARTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PARTS
    primary_key:
      columns:
        - PART_ID
    dimensions:
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: PART_NAME
        expr: PART_NAME
        data_type: VARCHAR
      - name: CATEGORY
        expr: CATEGORY
        data_type: VARCHAR
      - name: SUBCATEGORY
        expr: SUBCATEGORY
        data_type: VARCHAR
      - name: UNIT_OF_MEASURE
        expr: UNIT_OF_MEASURE
        data_type: VARCHAR
      - name: CRITICAL_FLAG
        expr: CRITICAL_FLAG
        data_type: BOOLEAN
    facts:
      - name: STANDARD_COST
        expr: STANDARD_COST
        data_type: NUMBER
      - name: WEIGHT_KG
        expr: WEIGHT_KG
        data_type: NUMBER
  - name: PLANT_INVENTORY
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PLANT_INVENTORY
    primary_key:
      columns:
        - PLANT_ID
        - PART_ID
        - SNAPSHOT_DATE
    foreign_keys:
      - fkey_columns:
          - PART_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PARTS
        pkey_columns:
          - PART_ID
      - fkey_columns:
          - PLANT_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PLANTS
        pkey_columns:
          - PLANT_ID
    dimensions:
      - name: PLANT_ID
        expr: PLANT_ID
        data_type: VARCHAR
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: ON_HAND_QTY
        expr: ON_HAND_QTY
        data_type: NUMBER
      - name: SAFETY_STOCK_QTY
        expr: SAFETY_STOCK_QTY
        data_type: NUMBER
      - name: REORDER_POINT
        expr: REORDER_POINT
        data_type: NUMBER
    time_dimensions:
      - name: SNAPSHOT_DATE
        expr: SNAPSHOT_DATE
        data_type: DATE
    facts:
      - name: AVG_DAILY_USAGE
        expr: AVG_DAILY_USAGE
        data_type: NUMBER
relationships:
  - name: PLANT_INVENTORY_TO_PARTS
    left_table: PLANT_INVENTORY
    right_table: PARTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PART_ID
        right_column: PART_ID
  - name: PLANT_INVENTORY_TO_PLANTS
    left_table: PLANT_INVENTORY
    right_table: PLANTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PLANT_ID
        right_column: PLANT_ID
verified_queries:
  - name: 0;1
    question: What are the current days of inventory by plant and part, showing the
      lowest first?
    sql: SELECT pl.PLANT_NAME, pt.PART_NAME, pt.CATEGORY, pi.SNAPSHOT_DATE, pi.ON_HAND_QTY,
      pi.SAFETY_STOCK_QTY, pi.AVG_DAILY_USAGE, ROUND(pi.ON_HAND_QTY / NULLIF(pi.AVG_DAILY_USAGE,
      0), 1) AS days_of_inventory, CASE WHEN pi.ON_HAND_QTY < pi.SAFETY_STOCK_QTY
      THEN ''Below Safety Stock'' WHEN pi.ON_HAND_QTY < pi.REORDER_POINT THEN ''Reorder
      Required'' ELSE ''Adequate'' END AS inventory_status FROM plant_inventory AS pi
      JOIN plants AS pl ON pi.PLANT_ID = pl.PLANT_ID JOIN parts AS pt ON pi.PART_ID
      = pt.PART_ID WHERE pi.SNAPSHOT_DATE = CURRENT_DATE ORDER BY days_of_inventory
      ASC LIMIT 50
    verified_at: 1789210165
    verified_by: Semantic Model Generator
  - name: 1;1
    question: What is the average days of inventory by plant over the last 7 days?
    sql: SELECT pl.PLANT_NAME, ROUND(AVG(pi.ON_HAND_QTY / NULLIF(pi.AVG_DAILY_USAGE,
      0)), 1) AS avg_doi FROM plant_inventory AS pi JOIN plants AS pl ON pi.PLANT_ID
      = pl.PLANT_ID WHERE pi.SNAPSHOT_DATE >= DATEADD(DAY, -7, CURRENT_DATE) GROUP
      BY 1 ORDER BY avg_doi
    verified_at: 1789210165
    verified_by: Semantic Model Generator
  - name: 2;1
    question: What is the current inventory status by part category showing total
      items, items below safety stock, and items needing reorder?
    sql: SELECT pt.CATEGORY, COUNT(*) AS total_items, SUM(CASE WHEN pi.ON_HAND_QTY
      < pi.SAFETY_STOCK_QTY THEN 1 ELSE 0 END) AS below_safety_stock, SUM(CASE WHEN
      pi.ON_HAND_QTY < pi.REORDER_POINT THEN 1 ELSE 0 END) AS needs_reorder FROM plant_inventory
      AS pi JOIN parts AS pt ON pi.PART_ID = pt.PART_ID WHERE pi.SNAPSHOT_DATE = (SELECT
      MAX(SNAPSHOT_DATE) FROM plant_inventory) GROUP BY 1 ORDER BY below_safety_stock
      DESC
    verified_at: 1789210165
    verified_by: Semantic Model Generator
  - name: 3;1
    question: Which critical parts are currently below safety stock levels?
    sql: SELECT pl.PLANT_NAME, pt.PART_NAME, pt.CRITICAL_FLAG, pi.SNAPSHOT_DATE, pi.ON_HAND_QTY,
      pi.SAFETY_STOCK_QTY, ROUND(pi.ON_HAND_QTY / NULLIF(pi.AVG_DAILY_USAGE, 0), 1)
      AS days_of_inventory FROM plant_inventory AS pi JOIN plants AS pl ON pi.PLANT_ID
      = pl.PLANT_ID JOIN parts AS pt ON pi.PART_ID = pt.PART_ID WHERE pt.CRITICAL_FLAG
      = TRUE AND pi.ON_HAND_QTY < pi.SAFETY_STOCK_QTY AND pi.SNAPSHOT_DATE = (SELECT
      MAX(SNAPSHOT_DATE) FROM plant_inventory) ORDER BY days_of_inventory ASC
    verified_at: 1789210165
    verified_by: Semantic Model Generator';

-- ============================================================
-- Semantic View: SCM_FULFILLMENT (Fulfillment: Fill Rate)
-- ============================================================

CREATE OR REPLACE SEMANTIC VIEW __SF_DATABASE__.__SF_SCHEMA__.SCM_FULFILLMENT
  AS 'name: SCM_FULFILLMENT
description: Order fulfillment analytics for supply chain management. Tracks Fill
  Rate percentage across customers, plants, parts, and time periods. Used by sales,
  planning, and operations personas to measure order fulfillment effectiveness, identify
  underperforming segments, and ensure customer satisfaction.
tables:
  - name: CUSTOMERS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: CUSTOMERS
    primary_key:
      columns:
        - CUSTOMER_ID
    dimensions:
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: VARCHAR
      - name: CUSTOMER_NAME
        expr: CUSTOMER_NAME
        data_type: VARCHAR
      - name: SEGMENT
        expr: SEGMENT
        data_type: VARCHAR
      - name: INDUSTRY
        expr: INDUSTRY
        data_type: VARCHAR
      - name: CITY
        expr: CITY
        data_type: VARCHAR
      - name: COUNTRY
        expr: COUNTRY
        data_type: VARCHAR
      - name: REGION
        expr: REGION
        data_type: VARCHAR
      - name: PRIORITY
        expr: PRIORITY
        data_type: VARCHAR
  - name: SALES_ORDERS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: SALES_ORDERS
    primary_key:
      columns:
        - ORDER_ID
    foreign_keys:
      - fkey_columns:
          - CUSTOMER_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: CUSTOMERS
        pkey_columns:
          - CUSTOMER_ID
    dimensions:
      - name: ORDER_ID
        expr: ORDER_ID
        data_type: VARCHAR
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: VARCHAR
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
    time_dimensions:
      - name: ORDER_DATE
        expr: ORDER_DATE
        data_type: DATE
      - name: REQUESTED_DATE
        expr: REQUESTED_DATE
        data_type: DATE
  - name: ORDER_LINES
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: ORDER_LINES
    primary_key:
      columns:
        - ORDER_ID
        - LINE_NUM
    foreign_keys:
      - fkey_columns:
          - PART_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PARTS
        pkey_columns:
          - PART_ID
      - fkey_columns:
          - PLANT_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PLANTS
        pkey_columns:
          - PLANT_ID
      - fkey_columns:
          - ORDER_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: SALES_ORDERS
        pkey_columns:
          - ORDER_ID
    dimensions:
      - name: ORDER_ID
        expr: ORDER_ID
        data_type: VARCHAR
      - name: LINE_NUM
        expr: LINE_NUM
        data_type: NUMBER
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: PLANT_ID
        expr: PLANT_ID
        data_type: VARCHAR
      - name: ORDERED_QTY
        expr: ORDERED_QTY
        data_type: NUMBER
      - name: FULFILLED_QTY
        expr: FULFILLED_QTY
        data_type: NUMBER
      - name: LINE_STATUS
        expr: LINE_STATUS
        data_type: VARCHAR
    facts:
      - name: UNIT_PRICE
        expr: UNIT_PRICE
        data_type: NUMBER
  - name: PARTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PARTS
    primary_key:
      columns:
        - PART_ID
    dimensions:
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: PART_NAME
        expr: PART_NAME
        data_type: VARCHAR
      - name: CATEGORY
        expr: CATEGORY
        data_type: VARCHAR
      - name: SUBCATEGORY
        expr: SUBCATEGORY
        data_type: VARCHAR
      - name: CRITICAL_FLAG
        expr: CRITICAL_FLAG
        data_type: BOOLEAN
    facts:
      - name: STANDARD_COST
        expr: STANDARD_COST
        data_type: NUMBER
  - name: PLANTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PLANTS
    primary_key:
      columns:
        - PLANT_ID
    dimensions:
      - name: PLANT_ID
        expr: PLANT_ID
        data_type: VARCHAR
      - name: PLANT_NAME
        expr: PLANT_NAME
        data_type: VARCHAR
      - name: CITY
        expr: CITY
        data_type: VARCHAR
      - name: COUNTRY
        expr: COUNTRY
        data_type: VARCHAR
      - name: REGION
        expr: REGION
        data_type: VARCHAR
      - name: PLANT_TYPE
        expr: PLANT_TYPE
        data_type: VARCHAR
relationships:
  - name: ORDER_LINES_TO_PARTS
    left_table: ORDER_LINES
    right_table: PARTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PART_ID
        right_column: PART_ID
  - name: ORDER_LINES_TO_PLANTS
    left_table: ORDER_LINES
    right_table: PLANTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PLANT_ID
        right_column: PLANT_ID
  - name: ORDER_LINES_TO_SALES_ORDERS
    left_table: ORDER_LINES
    right_table: SALES_ORDERS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: ORDER_ID
        right_column: ORDER_ID
  - name: SALES_ORDERS_TO_CUSTOMERS
    left_table: SALES_ORDERS
    right_table: CUSTOMERS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: CUSTOMER_ID
        right_column: CUSTOMER_ID
verified_queries:
  - name: 0;1
    question: What is the fill rate by customer and month?
    sql: SELECT c.CUSTOMER_NAME, c.SEGMENT, DATE_TRUNC(''MONTH'', so.ORDER_DATE) AS
      order_month, SUM(ol.ORDERED_QTY) AS total_ordered, SUM(ol.FULFILLED_QTY) AS
      total_fulfilled, ROUND(SUM(ol.FULFILLED_QTY) * 100.0 / NULLIF(SUM(ol.ORDERED_QTY),
      0), 2) AS fill_rate_pct FROM sales_orders AS so JOIN order_lines AS ol ON so.ORDER_ID
      = ol.ORDER_ID JOIN customers AS c ON so.CUSTOMER_ID = c.CUSTOMER_ID WHERE NOT
      so.STATUS IN (''Cancelled'') GROUP BY 1, 2, 3 ORDER BY 3 DESC, 6
    verified_at: 1789210166
    verified_by: Semantic Model Generator
  - name: 1;1
    question: What is the fill rate by plant and month?
    sql: SELECT pl.PLANT_NAME, pl.REGION, DATE_TRUNC(''MONTH'', so.ORDER_DATE) AS order_month,
      SUM(ol.ORDERED_QTY) AS total_ordered, SUM(ol.FULFILLED_QTY) AS total_fulfilled,
      ROUND(SUM(ol.FULFILLED_QTY) * 100.0 / NULLIF(SUM(ol.ORDERED_QTY), 0), 2) AS
      fill_rate_pct FROM sales_orders AS so JOIN order_lines AS ol ON so.ORDER_ID
      = ol.ORDER_ID JOIN plants AS pl ON ol.PLANT_ID = pl.PLANT_ID WHERE NOT so.STATUS
      IN (''Cancelled'') GROUP BY 1, 2, 3 ORDER BY 3 DESC, 6
    verified_at: 1789210166
    verified_by: Semantic Model Generator
  - name: 2;1
    question: What is the fill rate by customer segment and priority?
    sql: SELECT c.SEGMENT, c.PRIORITY, COUNT(DISTINCT so.ORDER_ID) AS total_orders,
      SUM(ol.ORDERED_QTY) AS total_ordered, SUM(ol.FULFILLED_QTY) AS total_fulfilled,
      ROUND(SUM(ol.FULFILLED_QTY) * 100.0 / NULLIF(SUM(ol.ORDERED_QTY), 0), 2) AS
      fill_rate_pct FROM sales_orders AS so JOIN order_lines AS ol ON so.ORDER_ID
      = ol.ORDER_ID JOIN customers AS c ON so.CUSTOMER_ID = c.CUSTOMER_ID WHERE NOT
      so.STATUS IN (''Cancelled'') GROUP BY 1, 2 ORDER BY fill_rate_pct
    verified_at: 1789210166
    verified_by: Semantic Model Generator
  - name: 3;1
    question: Which parts have the lowest fill rate?
    sql: SELECT pt.CATEGORY, pt.PART_NAME, SUM(ol.ORDERED_QTY) AS total_ordered, SUM(ol.FULFILLED_QTY)
      AS total_fulfilled, ROUND(SUM(ol.FULFILLED_QTY) * 100.0 / NULLIF(SUM(ol.ORDERED_QTY),
      0), 2) AS fill_rate_pct FROM order_lines AS ol JOIN parts AS pt ON ol.PART_ID
      = pt.PART_ID JOIN sales_orders AS so ON ol.ORDER_ID = so.ORDER_ID WHERE NOT
      so.STATUS IN (''Cancelled'') GROUP BY 1, 2 ORDER BY fill_rate_pct ASC LIMIT 20
    verified_at: 1789210166
    verified_by: Semantic Model Generator
  - name: 4;1
    question: What is the overall fill rate trend by month?
    sql: SELECT DATE_TRUNC(''MONTH'', so.ORDER_DATE) AS order_month, SUM(ol.ORDERED_QTY)
      AS total_ordered, SUM(ol.FULFILLED_QTY) AS total_fulfilled, ROUND(SUM(ol.FULFILLED_QTY)
      * 100.0 / NULLIF(SUM(ol.ORDERED_QTY), 0), 2) AS fill_rate_pct FROM sales_orders
      AS so JOIN order_lines AS ol ON so.ORDER_ID = ol.ORDER_ID WHERE NOT so.STATUS
      IN (''Cancelled'') GROUP BY 1 ORDER BY 1
    verified_at: 1789210166
    verified_by: Semantic Model Generator';

-- ============================================================
-- Semantic View: SCM_LOGISTICS (Logistics: Delivery OTD)
-- ============================================================

CREATE OR REPLACE SEMANTIC VIEW __SF_DATABASE__.__SF_SCHEMA__.SCM_LOGISTICS
  AS 'name: SCM_LOGISTICS
description: Logistics and shipment analytics for supply chain management. Tracks
  customer-facing Delivery On-Time Delivery (OTD) rate, freight costs, transit times,
  and carrier performance. Used by logistics, operations, and customer service personas
  to monitor delivery reliability and optimize transportation costs.
tables:
  - name: SHIPMENTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: SHIPMENTS
    primary_key:
      columns:
        - SHIPMENT_ID
    foreign_keys:
      - fkey_columns:
          - CUSTOMER_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: CUSTOMERS
        pkey_columns:
          - CUSTOMER_ID
      - fkey_columns:
          - PLANT_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PLANTS
        pkey_columns:
          - PLANT_ID
      - fkey_columns:
          - ORDER_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: SALES_ORDERS
        pkey_columns:
          - ORDER_ID
    dimensions:
      - name: SHIPMENT_ID
        expr: SHIPMENT_ID
        data_type: VARCHAR
      - name: ORDER_ID
        expr: ORDER_ID
        data_type: VARCHAR
      - name: PLANT_ID
        expr: PLANT_ID
        data_type: VARCHAR
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: VARCHAR
      - name: CARRIER
        expr: CARRIER
        data_type: VARCHAR
      - name: TRANSPORT_MODE
        expr: TRANSPORT_MODE
        data_type: VARCHAR
      - name: STATUS
        expr: STATUS
        data_type: VARCHAR
    time_dimensions:
      - name: SHIP_DATE
        expr: SHIP_DATE
        data_type: DATE
      - name: PROMISED_DELIVERY
        expr: PROMISED_DELIVERY
        data_type: DATE
      - name: ACTUAL_DELIVERY
        expr: ACTUAL_DELIVERY
        data_type: DATE
    facts:
      - name: FREIGHT_COST
        expr: FREIGHT_COST
        data_type: NUMBER
  - name: SHIPMENT_LINES
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: SHIPMENT_LINES
    primary_key:
      columns:
        - SHIPMENT_ID
        - LINE_NUM
    foreign_keys:
      - fkey_columns:
          - PART_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: PARTS
        pkey_columns:
          - PART_ID
      - fkey_columns:
          - SHIPMENT_ID
        pkey_table:
          database: __SF_DATABASE__
          schema: __SF_SCHEMA__
          table: SHIPMENTS
        pkey_columns:
          - SHIPMENT_ID
    dimensions:
      - name: SHIPMENT_ID
        expr: SHIPMENT_ID
        data_type: VARCHAR
      - name: LINE_NUM
        expr: LINE_NUM
        data_type: NUMBER
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: SHIPPED_QTY
        expr: SHIPPED_QTY
        data_type: NUMBER
  - name: CUSTOMERS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: CUSTOMERS
    primary_key:
      columns:
        - CUSTOMER_ID
    dimensions:
      - name: CUSTOMER_ID
        expr: CUSTOMER_ID
        data_type: VARCHAR
      - name: CUSTOMER_NAME
        expr: CUSTOMER_NAME
        data_type: VARCHAR
      - name: SEGMENT
        expr: SEGMENT
        data_type: VARCHAR
      - name: INDUSTRY
        expr: INDUSTRY
        data_type: VARCHAR
      - name: COUNTRY
        expr: COUNTRY
        data_type: VARCHAR
      - name: REGION
        expr: REGION
        data_type: VARCHAR
      - name: PRIORITY
        expr: PRIORITY
        data_type: VARCHAR
  - name: PLANTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PLANTS
    primary_key:
      columns:
        - PLANT_ID
    dimensions:
      - name: PLANT_ID
        expr: PLANT_ID
        data_type: VARCHAR
      - name: PLANT_NAME
        expr: PLANT_NAME
        data_type: VARCHAR
      - name: CITY
        expr: CITY
        data_type: VARCHAR
      - name: COUNTRY
        expr: COUNTRY
        data_type: VARCHAR
      - name: REGION
        expr: REGION
        data_type: VARCHAR
      - name: PLANT_TYPE
        expr: PLANT_TYPE
        data_type: VARCHAR
  - name: PARTS
    base_table:
      database: __SF_DATABASE__
      schema: __SF_SCHEMA__
      table: PARTS
    primary_key:
      columns:
        - PART_ID
    dimensions:
      - name: PART_ID
        expr: PART_ID
        data_type: VARCHAR
      - name: PART_NAME
        expr: PART_NAME
        data_type: VARCHAR
      - name: CATEGORY
        expr: CATEGORY
        data_type: VARCHAR
      - name: CRITICAL_FLAG
        expr: CRITICAL_FLAG
        data_type: BOOLEAN
relationships:
  - name: SHIPMENTS_TO_CUSTOMERS
    left_table: SHIPMENTS
    right_table: CUSTOMERS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: CUSTOMER_ID
        right_column: CUSTOMER_ID
  - name: SHIPMENTS_TO_PLANTS
    left_table: SHIPMENTS
    right_table: PLANTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PLANT_ID
        right_column: PLANT_ID
  - name: SHIPMENT_LINES_TO_PARTS
    left_table: SHIPMENT_LINES
    right_table: PARTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: PART_ID
        right_column: PART_ID
  - name: SHIPMENT_LINES_TO_SHIPMENTS
    left_table: SHIPMENT_LINES
    right_table: SHIPMENTS
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: SHIPMENT_ID
        right_column: SHIPMENT_ID
verified_queries:
  - name: 0;1
    question: What is the delivery on-time rate by carrier and transport mode per
      month?
    sql: SELECT sh.CARRIER, sh.TRANSPORT_MODE, DATE_TRUNC(''MONTH'', sh.SHIP_DATE) AS
      ship_month, COUNT(*) AS total_shipments, SUM(CASE WHEN sh.STATUS = ''Delivered''
      AND sh.ACTUAL_DELIVERY <= sh.PROMISED_DELIVERY THEN 1 ELSE 0 END) AS on_time_deliveries,
      ROUND(on_time_deliveries * 100.0 / NULLIF(total_shipments, 0), 2) AS delivery_otd_pct
      FROM shipments AS sh WHERE sh.STATUS <> ''In Transit'' GROUP BY 1, 2, 3 ORDER
      BY 3 DESC, 6
    verified_at: 1789210167
    verified_by: Semantic Model Generator
  - name: 1;1
    question: What is the delivery on-time rate and average freight cost by customer?
    sql: SELECT c.CUSTOMER_NAME, c.SEGMENT, c.PRIORITY, COUNT(*) AS total_shipments,
      SUM(CASE WHEN sh.STATUS = ''Delivered'' AND sh.ACTUAL_DELIVERY <= sh.PROMISED_DELIVERY
      THEN 1 ELSE 0 END) AS on_time, ROUND(on_time * 100.0 / NULLIF(total_shipments,
      0), 2) AS delivery_otd_pct, ROUND(AVG(sh.FREIGHT_COST), 2) AS avg_freight_cost
      FROM shipments AS sh JOIN customers AS c ON sh.CUSTOMER_ID = c.CUSTOMER_ID WHERE
      sh.STATUS <> ''In Transit'' GROUP BY 1, 2, 3 ORDER BY delivery_otd_pct
    verified_at: 1789210167
    verified_by: Semantic Model Generator
  - name: 2;1
    question: Which plants have the worst on-time delivery performance?
    sql: SELECT pl.PLANT_NAME, pl.REGION, COUNT(*) AS total_shipments, SUM(CASE WHEN
      sh.STATUS = ''Delivered'' AND sh.ACTUAL_DELIVERY <= sh.PROMISED_DELIVERY THEN
      1 ELSE 0 END) AS on_time, SUM(CASE WHEN sh.STATUS = ''Delayed'' THEN 1 ELSE 0
      END) AS delayed, ROUND(on_time * 100.0 / NULLIF(total_shipments, 0), 2) AS otd_pct
      FROM shipments AS sh JOIN plants AS pl ON sh.PLANT_ID = pl.PLANT_ID WHERE sh.STATUS
      <> ''In Transit'' GROUP BY 1, 2 ORDER BY otd_pct
    verified_at: 1789210167
    verified_by: Semantic Model Generator
  - name: 3;1
    question: What is the monthly trend for delivery on-time performance and freight
      costs?
    sql: SELECT DATE_TRUNC(''MONTH'', sh.SHIP_DATE) AS ship_month, COUNT(*) AS total_shipments,
      SUM(CASE WHEN sh.STATUS = ''Delivered'' AND sh.ACTUAL_DELIVERY <= sh.PROMISED_DELIVERY
      THEN 1 ELSE 0 END) AS on_time_deliveries, ROUND(on_time_deliveries * 100.0 /
      NULLIF(total_shipments, 0), 2) AS delivery_otd_pct, ROUND(AVG(sh.FREIGHT_COST),
      2) AS avg_freight_cost, SUM(sh.FREIGHT_COST) AS total_freight_cost FROM shipments
      AS sh WHERE sh.STATUS <> ''In Transit'' GROUP BY 1 ORDER BY 1
    verified_at: 1789210167
    verified_by: Semantic Model Generator
  - name: 4;1
    question: What is the average transit time and freight cost by transport mode
      for delivered shipments?
    sql: SELECT sh.TRANSPORT_MODE, ROUND(AVG(DATEDIFF(DAY, sh.SHIP_DATE, sh.ACTUAL_DELIVERY)),
      1) AS avg_transit_days, ROUND(AVG(sh.FREIGHT_COST), 2) AS avg_freight_cost,
      COUNT(*) AS shipment_count FROM shipments AS sh WHERE sh.STATUS = ''Delivered''
      GROUP BY 1 ORDER BY avg_transit_days
    verified_at: 1789210167
    verified_by: Semantic Model Generator';

-- ============================================================
-- Verify deployment
-- ============================================================

SHOW SEMANTIC VIEWS IN SCHEMA __SF_DATABASE__.__SF_SCHEMA__;


-- ============================================================
-- Cortex Agent: SCM_ANALYST (Cross-Domain Conversational Analytics)
-- Wires all 4 semantic views into a single governed agent
-- ============================================================

CREATE OR REPLACE AGENT __SF_DATABASE__.__SF_SCHEMA__.SCM_ANALYST
  SPEC = 'models:
  orchestration: "auto"

instructions:
  system: >-
    You are the Supply Chain Analyst — a governed conversational analytics agent
    for manufacturing supply chain management. You answer questions across four
    domains using canonical, governed metrics so that every persona (procurement,
    planning, logistics, sales) gets the same trustworthy answer.

    The four canonical supply chain metrics you govern are:
    1. **On-Time Delivery (OTD)** — percentage of purchase orders received by the
       promised date. Use the procurement_analytics tool.
    2. **Landed Cost** — total cost of goods including material, freight, duty, and
       handling per unit. Use the procurement_analytics tool.
    3. **Days of Inventory (DOI)** — on-hand quantity divided by average daily usage,
       measuring how many days current stock will last. Use the inventory_analytics tool.
    4. **Fill Rate** — percentage of customer-ordered quantity that was actually
       fulfilled. Use the fulfillment_analytics tool.
    5. **Delivery OTD** — percentage of shipments delivered to customers on or before
       the promised date. Use the logistics_analytics tool.

    When a question spans multiple domains, query each relevant tool and synthesize
    a unified answer. Always name the metric definition so the user knows exactly
    what was measured.

  orchestration: >-
    Route questions using these rules:
    - Supplier performance, purchase orders, lead times, landed cost, procurement OTD
      → procurement_analytics
    - Inventory levels, days of inventory, safety stock, reorder, stockout risk
      → inventory_analytics
    - Customer orders, fill rate, order fulfillment, order lines
      → fulfillment_analytics
    - Shipments, delivery OTD, carriers, transport modes, freight cost, transit time
      → logistics_analytics
    - Cross-domain or executive summary questions → query multiple tools and combine

  response: >-
    Be concise and data-driven. Present numbers in tables when comparing across
    entities. Always state the metric name and its definition on first use.
    Round percentages to 2 decimal places. When showing trends, order by time
    ascending. If a question is ambiguous about which metric to use, state the
    metric you chose and why.

  sample_questions:
    - question: "What is the on-time delivery rate by supplier this quarter?"
    - question: "Which plants have the lowest days of inventory for critical parts?"
    - question: "What is the fill rate by customer segment this month?"
    - question: "Which carrier has the best delivery OTD?"
    - question: "Compare the landed cost per unit across supplier regions"
    - question: "Give me an executive summary of all supply chain KPIs for the last 3 months"
    - question: "Which suppliers have both high OTD and low landed cost?"
    - question: "Are there parts with low fill rate that are also below safety stock?"

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "procurement_analytics"
      description: >-
        Procurement domain analytics. Query supplier performance metrics including
        On-Time Delivery (OTD) rate, Landed Cost per unit (material + freight + duty +
        handling), supplier lead time compliance, and purchase order analysis. Covers
        tables: SUPPLIERS, PARTS, PLANTS, SUPPLIER_PARTS, PURCHASE_ORDERS.

  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "inventory_analytics"
      description: >-
        Inventory domain analytics. Query Days of Inventory (DOI), safety stock
        coverage, reorder status, and inventory health across plants and parts.
        Covers tables: PLANTS, PARTS, PLANT_INVENTORY.

  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "fulfillment_analytics"
      description: >-
        Order fulfillment domain analytics. Query Fill Rate percentage, ordered vs
        fulfilled quantities, and order line status across customers, plants, parts,
        and time periods. Covers tables: CUSTOMERS, SALES_ORDERS, ORDER_LINES, PARTS, PLANTS.

  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "logistics_analytics"
      description: >-
        Logistics and shipment domain analytics. Query Delivery On-Time Delivery (OTD)
        rate, freight costs, transit times, carrier and transport mode performance.
        Covers tables: SHIPMENTS, SHIPMENT_LINES, CUSTOMERS, PLANTS, PARTS.

tool_resources:
  procurement_analytics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_PROCUREMENT"

  inventory_analytics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_INVENTORY"

  fulfillment_analytics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_FULFILLMENT"

  logistics_analytics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_LOGISTICS"';

-- Verify agent deployment
SHOW AGENTS IN SCHEMA __SF_DATABASE__.__SF_SCHEMA__;

-- ============================================================
-- Summary of deployed objects
-- ============================================================
-- Semantic Views:
--   SCM_PROCUREMENT  (OTD, Landed Cost)        - 5 VQRs
--   SCM_INVENTORY    (Days of Inventory)        - 4 VQRs
--   SCM_FULFILLMENT  (Fill Rate)                - 5 VQRs
--   SCM_LOGISTICS    (Delivery OTD)             - 5 VQRs
-- 
-- Cortex Agent:
--   SCM_ANALYST - Cross-domain governed analytics agent
--     Tools: procurement_analytics, inventory_analytics,
--            fulfillment_analytics, logistics_analytics
-- ============================================================
