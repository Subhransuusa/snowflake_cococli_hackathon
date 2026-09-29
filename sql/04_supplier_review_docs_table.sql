-- ============================================================
-- Supplier Review Documents Table (for Cortex Search)
-- ============================================================
USE DATABASE __SF_DATABASE__;
USE SCHEMA __SF_SCHEMA__;

CREATE OR REPLACE TABLE SUPPLIER_REVIEW_DOCS (
    DOC_ID             VARCHAR(20) NOT NULL PRIMARY KEY,
    SUPPLIER_ID        VARCHAR(10) NOT NULL,
    SUPPLIER_NAME      VARCHAR(100),
    REVIEW_TEXT        VARCHAR(16777216),
    RATING_DATE        DATE,
    OVERALL_RATING     FLOAT,
    RISK_LEVEL         VARCHAR(10),
    RECOMMENDATION     VARCHAR(5000)
);
