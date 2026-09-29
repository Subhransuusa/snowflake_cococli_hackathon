-- ============================================================
-- Phase 3: Cortex Search Service for Supplier Review Documents
-- ============================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE __SF_DATABASE__.__SF_SCHEMA__.SUPPLIER_REVIEW_SEARCH
  ON REVIEW_TEXT
  ATTRIBUTES SUPPLIER_ID, SUPPLIER_NAME, OVERALL_RATING, RISK_LEVEL, RECOMMENDATION
  WAREHOUSE = __SF_WAREHOUSE__
  TARGET_LAG = '1 hour'
  AS (
    SELECT DOC_ID, SUPPLIER_ID, SUPPLIER_NAME, REVIEW_TEXT,
           OVERALL_RATING, RISK_LEVEL, RECOMMENDATION
    FROM __SF_DATABASE__.__SF_SCHEMA__.SUPPLIER_REVIEW_DOCS
  );
