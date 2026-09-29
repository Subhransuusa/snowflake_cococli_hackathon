-- ============================================================
-- DML: Core Ontology Synthetic Data
-- 15 suppliers, 20 parts, 8 plants, 20 customers
-- 35 supplier-parts, 9450 plant-inventory, 428 POs
-- 400 sales orders, 830 order lines, 329 shipments, 760 shipment lines
-- ============================================================

USE DATABASE __SF_DATABASE__;
USE SCHEMA __SF_SCHEMA__;

-- DML: Synthetic Data - SUPPLIERS (15 suppliers across tiers)
-- ============================================================

INSERT INTO SUPPLIERS (SUPPLIER_ID, SUPPLIER_NAME, COUNTRY, REGION, TIER, LEAD_TIME_DAYS, RELIABILITY_SCORE, ACTIVE) VALUES
('SUP001', 'Apex Materials Corp',       'United States', 'North America', 1, 7,  96.50, TRUE),
('SUP002', 'Yangtze Components Ltd',    'China',         'Asia Pacific',  2, 21, 88.20, TRUE),
('SUP003', 'Rhine Precision GmbH',      'Germany',       'Europe',        1, 10, 97.80, TRUE),
('SUP004', 'Tata Industrial Supply',    'India',         'Asia Pacific',  2, 18, 85.40, TRUE),
('SUP005', 'Maple Fasteners Inc',       'Canada',        'North America', 2, 8,  91.30, TRUE),
('SUP006', 'Sakura Electronics Co',     'Japan',         'Asia Pacific',  1, 14, 98.10, TRUE),
('SUP007', 'Sao Paulo Metals SA',       'Brazil',        'South America', 3, 25, 78.60, TRUE),
('SUP008', 'Nordic Alloys AB',          'Sweden',        'Europe',        2, 12, 92.70, TRUE),
('SUP009', 'Delta Plastics LLC',        'United States', 'North America', 3, 5,  82.40, TRUE),
('SUP010', 'Seoul Semiconductor Inc',   'South Korea',   'Asia Pacific',  1, 15, 95.90, TRUE),
('SUP011', 'Anatolian Castings AS',     'Turkey',        'Europe',        3, 20, 79.50, TRUE),
('SUP012', 'Melbourne Rubber Pty',      'Australia',     'Asia Pacific',  3, 22, 81.30, TRUE),
('SUP013', 'Guadalajara Motors SA',     'Mexico',        'North America', 2, 9,  89.70, TRUE),
('SUP014', 'Thames Bearings Ltd',       'United Kingdom','Europe',        1, 11, 94.20, TRUE),
('SUP015', 'Shenzhen PCB Tech Co',      'China',         'Asia Pacific',  2, 19, 87.60, TRUE);

-- ============================================================
-- DML: Synthetic Data - PARTS (20 parts across categories)
-- ============================================================

INSERT INTO PARTS (PART_ID, PART_NAME, CATEGORY, SUBCATEGORY, UNIT_OF_MEASURE, STANDARD_COST, WEIGHT_KG, CRITICAL_FLAG) VALUES
('PRT001', 'Steel Mounting Bracket',    'Structural',    'Brackets',       'EA', 12.50,  0.450, FALSE),
('PRT002', 'Servo Motor Assembly',      'Electrical',    'Motors',         'EA', 245.00, 2.100, TRUE),
('PRT003', 'Hydraulic Cylinder 50mm',   'Hydraulics',    'Cylinders',      'EA', 189.00, 3.800, TRUE),
('PRT004', 'Nylon Bushing Kit',         'Consumables',   'Bushings',       'KIT', 8.75,  0.120, FALSE),
('PRT005', 'Control Board PCB v3',      'Electronics',   'PCBs',           'EA', 67.30,  0.085, TRUE),
('PRT006', 'Aluminum Extrusion 2m',     'Structural',    'Extrusions',     'EA', 34.20,  1.600, FALSE),
('PRT007', 'Bearing SKF 6205',          'Mechanical',    'Bearings',       'EA', 15.80,  0.210, FALSE),
('PRT008', 'Pneumatic Valve 3-way',     'Pneumatics',    'Valves',         'EA', 52.40,  0.380, FALSE),
('PRT009', 'Rubber Seal O-Ring Set',    'Consumables',   'Seals',          'KIT', 3.20,  0.045, FALSE),
('PRT010', 'Stainless Shaft 25mm',      'Structural',    'Shafts',         'EA', 28.90,  1.200, FALSE),
('PRT011', 'Power Supply 24V 10A',      'Electrical',    'Power',          'EA', 78.50,  0.950, TRUE),
('PRT012', 'Timing Belt HTD 5M',        'Mechanical',    'Belts',          'EA', 22.10,  0.180, FALSE),
('PRT013', 'Proximity Sensor NPN',      'Electronics',   'Sensors',        'EA', 41.60,  0.065, FALSE),
('PRT014', 'Cast Iron Housing',         'Structural',    'Housings',       'EA', 95.00,  5.400, FALSE),
('PRT015', 'Copper Wire Harness',       'Electrical',    'Wiring',         'EA', 56.80,  0.720, FALSE),
('PRT016', 'Thermal Paste Tube 50g',    'Consumables',   'Thermal',        'EA', 6.40,   0.055, FALSE),
('PRT017', 'Gearbox Planetary 10:1',    'Mechanical',    'Gearboxes',      'EA', 310.00, 4.200, TRUE),
('PRT018', 'LED Indicator Panel',       'Electronics',   'Displays',       'EA', 29.50,  0.140, FALSE),
('PRT019', 'Silicone Hose 12mm',        'Pneumatics',    'Hoses',          'M',  4.80,   0.095, FALSE),
('PRT020', 'Spring Compression 50N',    'Mechanical',    'Springs',        'EA', 2.90,   0.035, FALSE);

-- ============================================================
-- DML: Synthetic Data - PLANTS (8 plants)
-- ============================================================

INSERT INTO PLANTS (PLANT_ID, PLANT_NAME, CITY, COUNTRY, REGION, PLANT_TYPE, CAPACITY_UNITS, ACTIVE) VALUES
('PLT001', 'Detroit Assembly Hub',      'Detroit',       'United States', 'North America', 'Assembly',       50000, TRUE),
('PLT002', 'Stuttgart Manufacturing',   'Stuttgart',     'Germany',       'Europe',        'Manufacturing',  35000, TRUE),
('PLT003', 'Shanghai Mega Plant',       'Shanghai',      'China',         'Asia Pacific',  'Manufacturing',  80000, TRUE),
('PLT004', 'Monterrey Operations',      'Monterrey',     'Mexico',        'North America', 'Assembly',       40000, TRUE),
('PLT005', 'Chennai Production Center', 'Chennai',       'India',         'Asia Pacific',  'Manufacturing',  45000, TRUE),
('PLT006', 'Toronto Distribution',      'Toronto',       'Canada',        'North America', 'Distribution',   60000, TRUE),
('PLT007', 'Prague Assembly Works',     'Prague',        'Czech Republic','Europe',        'Assembly',       30000, TRUE),
('PLT008', 'Nagoya Precision Plant',    'Nagoya',        'Japan',         'Asia Pacific',  'Manufacturing',  25000, TRUE);

-- ============================================================
-- DML: Synthetic Data - CUSTOMERS (20 customers)
-- ============================================================

INSERT INTO CUSTOMERS (CUSTOMER_ID, CUSTOMER_NAME, SEGMENT, INDUSTRY, CITY, COUNTRY, REGION, PRIORITY) VALUES
('CUS001', 'Titan Automotive Group',    'Enterprise',  'Automotive',      'Detroit',       'United States', 'North America', 'High'),
('CUS002', 'EuroTech Industries AG',    'Enterprise',  'Industrial',      'Munich',        'Germany',       'Europe',        'High'),
('CUS003', 'Pacific Manufacturing Co',  'Mid-Market',  'Manufacturing',   'Osaka',         'Japan',         'Asia Pacific',  'Medium'),
('CUS004', 'Northwind Aerospace Ltd',   'Enterprise',  'Aerospace',       'London',        'United Kingdom','Europe',        'High'),
('CUS005', 'Green Valley Energy',       'Mid-Market',  'Energy',          'Denver',        'United States', 'North America', 'Medium'),
('CUS006', 'Atlas Construction SA',     'Mid-Market',  'Construction',    'Madrid',        'Spain',         'Europe',        'Medium'),
('CUS007', 'Horizon Medical Devices',   'Enterprise',  'Healthcare',      'Boston',        'United States', 'North America', 'High'),
('CUS008', 'Dragon Heavy Industries',   'Enterprise',  'Heavy Industry',  'Beijing',       'China',         'Asia Pacific',  'High'),
('CUS009', 'Maple Leaf Robotics',       'SMB',         'Robotics',        'Vancouver',     'Canada',        'North America', 'Low'),
('CUS010', 'Fjord Marine Systems',      'Mid-Market',  'Marine',          'Oslo',          'Norway',        'Europe',        'Medium'),
('CUS011', 'Southern Cross Mining',     'Enterprise',  'Mining',          'Perth',         'Australia',     'Asia Pacific',  'High'),
('CUS012', 'Ganges Textiles Ltd',       'SMB',         'Textile',         'Mumbai',        'India',         'Asia Pacific',  'Low'),
('CUS013', 'Liberty Defense Corp',      'Enterprise',  'Defense',         'Arlington',     'United States', 'North America', 'High'),
('CUS014', 'Andes Agricultural SA',     'Mid-Market',  'Agriculture',     'Santiago',      'Chile',         'South America', 'Medium'),
('CUS015', 'Rhine Pharma GmbH',        'Mid-Market',  'Pharmaceutical',  'Basel',         'Switzerland',   'Europe',        'Medium'),
('CUS016', 'Silk Road Electronics',     'SMB',         'Electronics',     'Istanbul',      'Turkey',        'Europe',        'Low'),
('CUS017', 'Great Plains Agri-Tech',    'SMB',         'Agriculture',     'Omaha',         'United States', 'North America', 'Low'),
('CUS018', 'Samurai Precision Tools',   'Mid-Market',  'Tooling',         'Tokyo',         'Japan',         'Asia Pacific',  'Medium'),
('CUS019', 'Nordic Wind Power AS',      'Mid-Market',  'Energy',          'Copenhagen',    'Denmark',       'Europe',        'Medium'),
('CUS020', 'Amazon Basin Logistics',    'SMB',         'Logistics',       'Manaus',        'Brazil',        'South America', 'Low');

-- ============================================================
-- DML: Synthetic Data - SUPPLIER_PARTS (supplier-part sourcing)
-- ============================================================

INSERT INTO SUPPLIER_PARTS (SUPPLIER_ID, PART_ID, UNIT_PRICE, MIN_ORDER_QTY, LEAD_TIME_DAYS, CONTRACT_START, CONTRACT_END) VALUES
('SUP001', 'PRT001', 11.80, 500,  7,  '2024-01-01', '2025-12-31'),
('SUP001', 'PRT006', 32.50, 200,  7,  '2024-01-01', '2025-12-31'),
('SUP001', 'PRT010', 27.40, 300,  8,  '2024-01-01', '2025-12-31'),
('SUP002', 'PRT005', 58.90, 1000, 21, '2024-03-01', '2025-12-31'),
('SUP002', 'PRT015', 48.20, 500,  20, '2024-03-01', '2025-12-31'),
('SUP003', 'PRT002', 238.00, 50,  10, '2024-01-01', '2026-06-30'),
('SUP003', 'PRT017', 295.00, 25,  12, '2024-01-01', '2026-06-30'),
('SUP004', 'PRT014', 82.00, 100,  18, '2024-06-01', '2025-12-31'),
('SUP004', 'PRT009', 2.80,  2000, 16, '2024-06-01', '2025-12-31'),
('SUP005', 'PRT001', 12.20, 400,  8,  '2024-02-01', '2025-12-31'),
('SUP005', 'PRT004', 7.90,  1000, 6,  '2024-02-01', '2025-12-31'),
('SUP006', 'PRT002', 242.00, 50,  14, '2024-01-01', '2026-06-30'),
('SUP006', 'PRT013', 38.50, 200,  14, '2024-01-01', '2026-06-30'),
('SUP006', 'PRT018', 27.80, 300,  13, '2024-01-01', '2026-06-30'),
('SUP007', 'PRT006', 30.10, 500,  25, '2024-04-01', '2025-12-31'),
('SUP007', 'PRT010', 25.50, 400,  24, '2024-04-01', '2025-12-31'),
('SUP008', 'PRT007', 14.90, 500,  12, '2024-01-01', '2025-12-31'),
('SUP008', 'PRT008', 49.80, 200,  11, '2024-01-01', '2025-12-31'),
('SUP009', 'PRT004', 8.10,  800,  5,  '2024-05-01', '2025-06-30'),
('SUP009', 'PRT009', 3.00,  1500, 4,  '2024-05-01', '2025-06-30'),
('SUP009', 'PRT019', 4.30,  1000, 5,  '2024-05-01', '2025-06-30'),
('SUP010', 'PRT005', 62.50, 500,  15, '2024-01-01', '2026-03-31'),
('SUP010', 'PRT011', 74.20, 100,  15, '2024-01-01', '2026-03-31'),
('SUP010', 'PRT013', 39.80, 200,  14, '2024-01-01', '2026-03-31'),
('SUP011', 'PRT014', 88.00, 150,  20, '2024-07-01', '2025-12-31'),
('SUP012', 'PRT009', 3.10,  1000, 22, '2024-06-01', '2025-12-31'),
('SUP012', 'PRT019', 4.60,  800,  21, '2024-06-01', '2025-12-31'),
('SUP013', 'PRT003', 175.00, 80,  9,  '2024-02-01', '2025-12-31'),
('SUP013', 'PRT012', 20.50, 500,  8,  '2024-02-01', '2025-12-31'),
('SUP013', 'PRT020', 2.60,  2000, 7,  '2024-02-01', '2025-12-31'),
('SUP014', 'PRT007', 15.40, 400,  11, '2024-01-01', '2025-12-31'),
('SUP014', 'PRT012', 21.30, 400,  10, '2024-01-01', '2025-12-31'),
('SUP015', 'PRT005', 55.80, 1500, 19, '2024-04-01', '2025-12-31'),
('SUP015', 'PRT011', 72.00, 200,  18, '2024-04-01', '2025-12-31'),
('SUP015', 'PRT018', 26.50, 500,  17, '2024-04-01', '2025-12-31');

-- ============================================================
-- DML: Synthetic Data - PLANT_INVENTORY (daily snapshots for last 90 days sample)
-- ============================================================

INSERT INTO PLANT_INVENTORY (PLANT_ID, PART_ID, SNAPSHOT_DATE, ON_HAND_QTY, SAFETY_STOCK_QTY, REORDER_POINT, AVG_DAILY_USAGE)
SELECT
    p.PLANT_ID,
    pt.PART_ID,
    d.SNAPSHOT_DATE,
    GREATEST(
        UNIFORM(50, 2000, RANDOM()) +
        CASE WHEN DAYOFWEEK(d.SNAPSHOT_DATE) IN (0,6) THEN 200 ELSE 0 END +
        CASE WHEN MONTH(d.SNAPSHOT_DATE) IN (11,12) THEN -300 ELSE 0 END,
        20
    ) AS ON_HAND_QTY,
    UNIFORM(100, 500, RANDOM()) AS SAFETY_STOCK_QTY,
    UNIFORM(200, 800, RANDOM()) AS REORDER_POINT,
    ROUND(UNIFORM(10, 150, RANDOM()) + UNIFORM(0, 50, RANDOM()) * 0.1, 2) AS AVG_DAILY_USAGE
FROM PLANTS p
CROSS JOIN PARTS pt
CROSS JOIN (
    SELECT DATEADD('day', -SEQ4(), CURRENT_DATE()) AS SNAPSHOT_DATE
    FROM TABLE(GENERATOR(ROWCOUNT => 90))
) d
WHERE MOD(ABS(HASH(p.PLANT_ID || pt.PART_ID)), 5) < 3;

-- ============================================================
-- DML: Synthetic Data - PURCHASE_ORDERS (500 POs over last 12 months)
-- ============================================================

INSERT INTO PURCHASE_ORDERS (PO_ID, SUPPLIER_ID, PLANT_ID, PART_ID, ORDER_DATE, PROMISED_DATE, RECEIVED_DATE, ORDERED_QTY, RECEIVED_QTY, UNIT_COST, FREIGHT_COST, DUTY_COST, HANDLING_COST, STATUS)
WITH po_base AS (
    SELECT
        'PO-' || LPAD(SEQ4() + 1, 8, '0') AS PO_ID,
        sp.SUPPLIER_ID,
        p.PLANT_ID,
        sp.PART_ID,
        DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS ORDER_DATE,
        sp.UNIT_PRICE AS UNIT_COST,
        sp.LEAD_TIME_DAYS,
        UNIFORM(50, 2000, RANDOM()) AS ORDERED_QTY,
        UNIFORM(1, 100, RANDOM()) AS RAND_PCT
    FROM SUPPLIER_PARTS sp
    CROSS JOIN PLANTS p
    CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 3)) g
    WHERE MOD(ABS(HASH(sp.SUPPLIER_ID || p.PLANT_ID || SEQ4())), 4) < 2
    LIMIT 500
)
SELECT
    PO_ID,
    SUPPLIER_ID,
    PLANT_ID,
    PART_ID,
    ORDER_DATE,
    DATEADD('day', LEAD_TIME_DAYS, ORDER_DATE) AS PROMISED_DATE,
    CASE
        WHEN RAND_PCT <= 5  THEN NULL  -- 5% still open
        WHEN RAND_PCT <= 8  THEN NULL  -- 3% cancelled
        WHEN RAND_PCT <= 20 THEN DATEADD('day', LEAD_TIME_DAYS + UNIFORM(1, 10, RANDOM()), ORDER_DATE)  -- 12% late
        ELSE DATEADD('day', LEAD_TIME_DAYS - UNIFORM(0, 3, RANDOM()), ORDER_DATE)  -- 80% on time or early
    END AS RECEIVED_DATE,
    ORDERED_QTY,
    CASE
        WHEN RAND_PCT <= 5  THEN NULL
        WHEN RAND_PCT <= 8  THEN 0
        WHEN RAND_PCT <= 15 THEN GREATEST(ROUND(ORDERED_QTY * UNIFORM(70, 95, RANDOM()) / 100), 1)
        ELSE ORDERED_QTY
    END AS RECEIVED_QTY,
    UNIT_COST,
    ROUND(ORDERED_QTY * UNIT_COST * UNIFORM(2, 8, RANDOM()) / 100, 2) AS FREIGHT_COST,
    ROUND(ORDERED_QTY * UNIT_COST * UNIFORM(0, 5, RANDOM()) / 100, 2) AS DUTY_COST,
    ROUND(ORDERED_QTY * UNIT_COST * UNIFORM(1, 3, RANDOM()) / 100, 2) AS HANDLING_COST,
    CASE
        WHEN RAND_PCT <= 5  THEN 'Open'
        WHEN RAND_PCT <= 8  THEN 'Cancelled'
        WHEN RAND_PCT <= 15 THEN 'Partial'
        ELSE 'Received'
    END AS STATUS
FROM po_base;

-- ============================================================
-- DML: Synthetic Data - SALES_ORDERS + ORDER_LINES (400 orders)
-- ============================================================

INSERT INTO SALES_ORDERS (ORDER_ID, CUSTOMER_ID, ORDER_DATE, REQUESTED_DATE, STATUS)
WITH so_base AS (
    SELECT
        'SO-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM()), 8, '0') AS ORDER_ID,
        c.CUSTOMER_ID,
        DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS ORDER_DATE,
        UNIFORM(1, 100, RANDOM()) AS RAND_PCT
    FROM CUSTOMERS c
    CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 20)) g
    LIMIT 400
)
SELECT
    ORDER_ID,
    CUSTOMER_ID,
    ORDER_DATE,
    DATEADD('day', UNIFORM(5, 30, RANDOM()), ORDER_DATE) AS REQUESTED_DATE,
    CASE
        WHEN RAND_PCT <= 5  THEN 'Open'
        WHEN RAND_PCT <= 8  THEN 'Cancelled'
        WHEN RAND_PCT <= 15 THEN 'Shipped'
        ELSE 'Delivered'
    END AS STATUS
FROM so_base;

INSERT INTO ORDER_LINES (ORDER_ID, LINE_NUM, PART_ID, PLANT_ID, ORDERED_QTY, FULFILLED_QTY, UNIT_PRICE, LINE_STATUS)
WITH line_base AS (
    SELECT
        so.ORDER_ID,
        so.STATUS AS ORDER_STATUS,
        ROW_NUMBER() OVER (PARTITION BY so.ORDER_ID ORDER BY RANDOM()) AS LINE_NUM,
        pt.PART_ID,
        pl.PLANT_ID,
        UNIFORM(10, 500, RANDOM()) AS ORDERED_QTY,
        pt.STANDARD_COST * (1 + UNIFORM(15, 45, RANDOM()) / 100.0) AS UNIT_PRICE,
        UNIFORM(1, 100, RANDOM()) AS RAND_PCT
    FROM SALES_ORDERS so
    CROSS JOIN PARTS pt
    CROSS JOIN PLANTS pl
    WHERE MOD(ABS(HASH(so.ORDER_ID || pt.PART_ID || pl.PLANT_ID)), 80) = 0
)
SELECT
    ORDER_ID,
    LINE_NUM,
    PART_ID,
    PLANT_ID,
    ORDERED_QTY,
    CASE
        WHEN ORDER_STATUS = 'Cancelled' THEN 0
        WHEN ORDER_STATUS = 'Open' THEN 0
        WHEN RAND_PCT <= 10 THEN GREATEST(ROUND(ORDERED_QTY * UNIFORM(60, 90, RANDOM()) / 100), 1)
        ELSE ORDERED_QTY
    END AS FULFILLED_QTY,
    ROUND(UNIT_PRICE, 2) AS UNIT_PRICE,
    CASE
        WHEN ORDER_STATUS = 'Cancelled' THEN 'Cancelled'
        WHEN ORDER_STATUS = 'Open' THEN 'Open'
        WHEN RAND_PCT <= 10 THEN 'Partial'
        ELSE 'Fulfilled'
    END AS LINE_STATUS
FROM line_base;

-- ============================================================
-- DML: Synthetic Data - SHIPMENTS + SHIPMENT_LINES
-- ============================================================

INSERT INTO SHIPMENTS (SHIPMENT_ID, ORDER_ID, PLANT_ID, CUSTOMER_ID, SHIP_DATE, PROMISED_DELIVERY, ACTUAL_DELIVERY, CARRIER, TRANSPORT_MODE, FREIGHT_COST, STATUS)
WITH ship_base AS (
    SELECT
        'SHP-' || LPAD(ROW_NUMBER() OVER (ORDER BY so.ORDER_DATE), 8, '0') AS SHIPMENT_ID,
        so.ORDER_ID,
        ol.PLANT_ID,
        so.CUSTOMER_ID,
        DATEADD('day', UNIFORM(1, 5, RANDOM()), so.ORDER_DATE) AS SHIP_DATE,
        so.REQUESTED_DATE AS PROMISED_DELIVERY,
        UNIFORM(1, 100, RANDOM()) AS RAND_PCT,
        ROW_NUMBER() OVER (PARTITION BY so.ORDER_ID ORDER BY RANDOM()) AS RN
    FROM SALES_ORDERS so
    JOIN ORDER_LINES ol ON so.ORDER_ID = ol.ORDER_ID AND ol.LINE_NUM = 1
    WHERE so.STATUS IN ('Shipped', 'Delivered')
)
SELECT
    SHIPMENT_ID,
    ORDER_ID,
    PLANT_ID,
    CUSTOMER_ID,
    SHIP_DATE,
    PROMISED_DELIVERY,
    CASE
        WHEN RAND_PCT <= 15 THEN DATEADD('day', UNIFORM(1, 7, RANDOM()), PROMISED_DELIVERY)  -- 15% late
        WHEN RAND_PCT <= 25 THEN NULL  -- 10% in transit
        ELSE DATEADD('day', -UNIFORM(0, 3, RANDOM()), PROMISED_DELIVERY)  -- 75% on time or early
    END AS ACTUAL_DELIVERY,
    CASE MOD(ABS(HASH(SHIPMENT_ID)), 5)
        WHEN 0 THEN 'FedEx Freight'
        WHEN 1 THEN 'DHL Supply Chain'
        WHEN 2 THEN 'XPO Logistics'
        WHEN 3 THEN 'Maersk Line'
        ELSE 'DB Schenker'
    END AS CARRIER,
    CASE MOD(ABS(HASH(SHIPMENT_ID || ORDER_ID)), 4)
        WHEN 0 THEN 'Truck'
        WHEN 1 THEN 'Rail'
        WHEN 2 THEN 'Air'
        ELSE 'Ocean'
    END AS TRANSPORT_MODE,
    ROUND(UNIFORM(200, 5000, RANDOM()) + UNIFORM(0, 500, RANDOM()) * 0.5, 2) AS FREIGHT_COST,
    CASE
        WHEN RAND_PCT <= 15 THEN 'Delayed'
        WHEN RAND_PCT <= 25 THEN 'In Transit'
        ELSE 'Delivered'
    END AS STATUS
FROM ship_base
WHERE RN = 1;

INSERT INTO SHIPMENT_LINES (SHIPMENT_ID, LINE_NUM, PART_ID, SHIPPED_QTY)
SELECT
    s.SHIPMENT_ID,
    ol.LINE_NUM,
    ol.PART_ID,
    ol.FULFILLED_QTY
FROM SHIPMENTS s
JOIN ORDER_LINES ol ON s.ORDER_ID = ol.ORDER_ID
WHERE ol.LINE_STATUS IN ('Fulfilled', 'Partial');

-- ============================================================
