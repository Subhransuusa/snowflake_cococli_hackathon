-- ============================================================
-- 05: Deploy All Agents to __SF_DATABASE__.__SF_SCHEMA__
-- Multi-Agent Orchestration for Supply Chain Management
-- ============================================================

USE DATABASE __SF_DATABASE__;
USE SCHEMA __SF_SCHEMA__;

-- ============================================================
-- Agent 1: SUPPLIER_REVIEWER
-- Domain: Procurement - Supplier quality reviews via Cortex Search
-- Called by: SCM_ROUTER for supplier selection decisions
-- ============================================================

CREATE OR REPLACE AGENT __SF_DATABASE__.__SF_SCHEMA__.SUPPLIER_REVIEWER
  COMMENT = 'Supplier Reviewer Agent - reviews supplier performance documents and ratings for procurement decisions'
  FROM SPECIFICATION $$
models:
  orchestration: "auto"
instructions:
  system: >-
    You are the Supplier Reviewer Agent. You review and evaluate supplier performance
    based on documented supplier rating reports. Search supplier review documents for
    quality scores, delivery performance, cost competitiveness, sustainability ratings,
    audit findings, capacity assessments, and risk classifications.
    Classification: PREFERRED (>85), APPROVED (70-85), PROBATIONARY (<70).
  orchestration: >-
    Use supplier_review_search for quality/reliability/risk/audit questions.
    Use supplier_ratings_data for quantitative comparisons and rankings.
  response: >-
    Structure recommendations with: supplier name, overall rating, risk level,
    key strengths, concerns, and classification.
  sample_questions:
    - question: "Which suppliers are rated PREFERRED?"
    - question: "Review Rhine Precision GmbH performance"
    - question: "Recommend the best supplier for electronic components"
tools:
  - tool_spec:
      type: "cortex_search"
      name: "supplier_review_search"
      description: "Search supplier performance review documents"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "supplier_ratings_data"
      description: "Query structured supplier rating data"
tool_resources:
  supplier_review_search:
    search_service: "__SF_DATABASE__.__SF_SCHEMA__.SUPPLIER_REVIEW_SEARCH"
    max_results: 5
  supplier_ratings_data:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_PROCUREMENT"
$$;

-- ============================================================
-- Agent 2: DEMAND_FORECASTER
-- Domain: Demand - Predicts future demand from market trends
-- Called by: SCM_ROUTER for demand planning and PO behavior
-- ============================================================

CREATE OR REPLACE AGENT __SF_DATABASE__.__SF_SCHEMA__.DEMAND_FORECASTER
  COMMENT = 'Demand Forecasting Agent - predicts future demand and market trends for purchase order planning'
  FROM SPECIFICATION $$
models:
  orchestration: "auto"
instructions:
  system: >-
    You are the Demand Forecasting Agent. You predict future demand and analyze
    market trends. Access part-level demand forecasts (12-week forward), weekly
    market trend data by region and category.
    Key metrics: FORECAST_QTY, TREND_SIGNAL, YOY_GROWTH_PCT, TREND_SLOPE.
  orchestration: >-
    Use demand_forecast_analytics for forecasts, trends, and demand predictions.
  response: >-
    Include confidence scores with forecasts. Show trend direction signals.
    Present forecasts with lower/upper bounds. Recommend PO actions.
  sample_questions:
    - question: "What is the demand forecast for critical parts?"
    - question: "Which categories show growing demand in North America?"
    - question: "What POs should we plan for next month?"
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "demand_forecast_analytics"
      description: "Query demand forecasts, market trends, and demand signals"
tool_resources:
  demand_forecast_analytics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SV_DEMAND_FORECAST"
$$;

-- ============================================================
-- Agent 3: ROUTE_OPTIMIZER
-- Domain: Logistics - Geospatial route optimization
-- Called by: SCM_ROUTER for shipping route decisions
-- ============================================================

CREATE OR REPLACE AGENT __SF_DATABASE__.__SF_SCHEMA__.ROUTE_OPTIMIZER
  COMMENT = 'Route Optimizer Agent - determines optimal shipping routes using geospatial data'
  FROM SPECIFICATION $$
models:
  orchestration: "auto"
instructions:
  system: >-
    You are the Route Optimizer Agent. You determine optimal shipping routes based
    on supplier and plant geolocation data. Analyze distances, transport modes,
    transit times, costs, risk levels, and trade lanes.
    Criteria: COST, SPEED, RISK, MODE (Truck/Rail/Ocean/Air).
  orchestration: >-
    Use route_geospatial_data for ALL route optimization queries.
  response: >-
    Present routes in tables: Route, Supplier, Plant, Distance, Mode, Transit Days,
    Cost, Risk. Highlight recommended route and explain trade-offs.
  sample_questions:
    - question: "Optimal route from Rhine Precision to Detroit Assembly?"
    - question: "Cheapest routes from Asia Pacific to North America?"
    - question: "Which routes have highest risk?"
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "route_geospatial_data"
      description: "Query shipping routes, geolocations, distances, costs, risk"
tool_resources:
  route_geospatial_data:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SV_GEOSPATIAL_DEMAND"
$$;

-- ============================================================
-- Stage for Domain Skills (instruction files)
-- ============================================================
CREATE OR REPLACE STAGE __SF_DATABASE__.__SF_SCHEMA__.AGENT_SKILLS
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  COMMENT = 'Domain skills for SCM multi-agent orchestration';

-- Upload skill files (run from CLI):
-- PUT file:///path/to/procurement_skill/SKILL.md @AGENT_SKILLS/skills/procurement_skill/ AUTO_COMPRESS=FALSE;
-- PUT file:///path/to/logistics_skill/SKILL.md @AGENT_SKILLS/skills/logistics_skill/ AUTO_COMPRESS=FALSE;
-- PUT file:///path/to/demand_skill/SKILL.md @AGENT_SKILLS/skills/demand_skill/ AUTO_COMPRESS=FALSE;
-- PUT file:///path/to/supplier_review_skill/SKILL.md @AGENT_SKILLS/skills/supplier_review_skill/ AUTO_COMPRESS=FALSE;
-- PUT file:///path/to/route_optimizer_skill/SKILL.md @AGENT_SKILLS/skills/route_optimizer_skill/ AUTO_COMPRESS=FALSE;

-- ============================================================
-- Agent 4: SCM_ROUTER (Master Orchestrator)
-- Owns all 7 tools + 5 domain skills directly.
-- NOTE: Snowflake Cortex Agents do NOT support agent-to-agent
-- calls. The router does NOT delegate to other agents. It uses
-- skills (instruction files on a stage) for domain expertise
-- and tools (semantic views + search) for data access.
-- Standalone domain agents exist as parallel direct-access
-- entry points for persona-specific use, NOT as sub-agents.
-- ============================================================

CREATE OR REPLACE AGENT __SF_DATABASE__.__SF_SCHEMA__.SCM_ROUTER
  COMMENT = 'SCM Router Agent - master orchestrator with 7 tools + 5 domain skills. Does NOT call other agents (platform limitation).'
  FROM SPECIFICATION $$
models:
  orchestration: "auto"
instructions:
  system: >-
    You are the SCM Router Agent — the master orchestrator for the supply chain
    multi-agent system. You have 7 data tools and 5 domain skills. Use the skills
    to adopt the right domain persona and expertise before querying data tools.
    Architecture: Skills provide domain expertise (how to interpret and present results).
    Tools provide data access (semantic views and search services).
    You combine the right skill + tool(s) for each question.
    Domain routing: Supplier OTD/cost/POs → procurement_skill + procurement_metrics.
    Fill rate/orders → procurement_skill + fulfillment_metrics.
    DOI/safety stock → demand_skill + inventory_metrics.
    Delivery OTD/carriers → logistics_skill + logistics_metrics.
    Supplier quality/audits → supplier_review_skill + supplier_reviews + procurement_metrics.
    Demand forecasts/trends → demand_skill + demand_analytics.
    Routes/geo/distances → route_optimizer_skill + route_data.
    Cross-domain/executive → combine multiple skills and tools, synthesize.
  orchestration: >-
    For every question: 1) Load the relevant domain skill(s) to adopt expertise.
    2) Use the skill instructions to guide which tool(s) to call.
    3) Query the data tool(s) for governed results.
    4) Apply the skill formatting rules.
    5) If cross-domain, load multiple skills and synthesize.
  response: >-
    Be concise and data-driven. Always state which domain skill and tool(s) you used.
    Present data in tables. State metric definitions on first use.
  sample_questions:
    - question: "Which supplier should we use for servo motor procurement?"
    - question: "What demand should we plan for in Electronics next quarter?"
    - question: "Optimal shipping route from Germany to Detroit?"
    - question: "Executive summary of all supply chain KPIs"
    - question: "Parts with growing demand but below safety stock?"
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "procurement_metrics"
      description: "Procurement data: Supplier OTD, landed cost, POs, lead times"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "fulfillment_metrics"
      description: "Fulfillment data: Fill rate, ordered vs fulfilled quantities"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "inventory_metrics"
      description: "Inventory data: DOI, safety stock, reorder status"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "logistics_metrics"
      description: "Logistics data: Delivery OTD, carriers, freight cost"
  - tool_spec:
      type: "cortex_search"
      name: "supplier_reviews"
      description: "Search supplier review documents for ratings, audits, risk"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "demand_analytics"
      description: "Demand data: Forecasts, market trends, YoY growth"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "route_data"
      description: "Route data: Shipping distances, costs, transit times, risk"
tool_resources:
  procurement_metrics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_PROCUREMENT"
  fulfillment_metrics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_FULFILLMENT"
  inventory_metrics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_INVENTORY"
  logistics_metrics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SCM_LOGISTICS"
  supplier_reviews:
    search_service: "__SF_DATABASE__.__SF_SCHEMA__.SUPPLIER_REVIEW_SEARCH"
    max_results: 5
  demand_analytics:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SV_DEMAND_FORECAST"
  route_data:
    execution_environment:
      type: "warehouse"
      warehouse: "__SF_WAREHOUSE__"
    semantic_view: "__SF_DATABASE__.__SF_SCHEMA__.SV_GEOSPATIAL_DEMAND"
skills:
  - name: "procurement_skill"
    source:
      type: "STAGE"
      path: "@__SF_DATABASE__.__SF_SCHEMA__.AGENT_SKILLS/skills/procurement_skill"
  - name: "logistics_skill"
    source:
      type: "STAGE"
      path: "@__SF_DATABASE__.__SF_SCHEMA__.AGENT_SKILLS/skills/logistics_skill"
  - name: "demand_skill"
    source:
      type: "STAGE"
      path: "@__SF_DATABASE__.__SF_SCHEMA__.AGENT_SKILLS/skills/demand_skill"
  - name: "supplier_review_skill"
    source:
      type: "STAGE"
      path: "@__SF_DATABASE__.__SF_SCHEMA__.AGENT_SKILLS/skills/supplier_review_skill"
  - name: "route_optimizer_skill"
    source:
      type: "STAGE"
      path: "@__SF_DATABASE__.__SF_SCHEMA__.AGENT_SKILLS/skills/route_optimizer_skill"
$$;

-- ============================================================
-- Verify all agents
-- ============================================================
SHOW AGENTS IN SCHEMA __SF_DATABASE__.__SF_SCHEMA__;
