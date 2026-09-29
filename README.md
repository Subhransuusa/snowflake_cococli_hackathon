# SCM Analytics Platform — Deploy-Ready Package

Multi-agent supply chain management system built on Snowflake Cortex AI.

## What's Included

| Component | Count | Description |
|-----------|-------|-------------|
| Tables | 19 | Core ontology (11) + geospatial/trend/rating (7) + docs (1) |
| Views | 6 | OTD, Fill Rate, DOI, Landed Cost, Shipment OTD, Executive Summary |
| Semantic Views | 6 | Procurement, Fulfillment, Inventory, Logistics, Demand Forecast, Geospatial |
| Cortex Search | 1 | Supplier review document search |
| Cortex Agents | 5 | SCM_ROUTER (master), SCM_ANALYST, SUPPLIER_REVIEWER, DEMAND_FORECASTER, ROUTE_OPTIMIZER |
| Streamlit App | 1 | SCM_COMMAND_CENTER — persona-based dashboard with AI chat |

## Prerequisites

- Snowflake account with Cortex AI features enabled
- A warehouse (default: `COMPUTE_WH`) — must already exist
- Role with CREATE DATABASE, CREATE SCHEMA, CREATE AGENT, CREATE SEMANTIC VIEW privileges
- Python 3.11+ (for data generation scripts)
- Snowflake CLI (`snow`) for Streamlit deployment

## Quick Start

### 1. Configure

Edit `config.env` with your Snowflake database, schema, and warehouse names:

```bash
SF_DATABASE=SCM_ANALYTICS    # Database name (created automatically)
SF_SCHEMA=SCM                # Schema name (created automatically)
SF_WAREHOUSE=COMPUTE_WH      # Must already exist in your account
```

### 2. Generate Resolved Files

```bash
bash deploy.sh --dry-run
```

This creates a `.deploy_output/` directory with all SQL, YAML, and Python files
with your configured values substituted in.

### 3. Deploy

Run the resolved SQL files in order:

```
Step 1:  sql/01_database_schema.sql           — Create DB + schema
Step 2:  sql/02_core_entity_tables.sql         — 11 core tables
Step 3:  sql/03_geospatial_tables.sql          — 7 geo/trend tables
Step 4:  sql/04_supplier_review_docs_table.sql — Docs table
Step 5:  sql/05_core_data.sql                  — Load synthetic data (SQL)
Step 6:  sql/06_metric_views.sql               — 6 metric views
Step 7:  sql/07_deploy_semantic_views.sql      — 6 semantic views
Step 8:  sql/08_cortex_search_service.sql      — Cortex Search service
Step 9:  sql/09_deploy_agents.sql              — 5 Cortex Agents + stage
Step 10: sql/10_governance_tables.sql          — Governance tables
```

### 4. Load CSV Data

```bash
cd .deploy_output
python python/generate_data.py
python python/load_csv_to_snowflake.py
```

### 5. Upload Agent Skill Files

Upload the 5 SKILL.md files to the AGENT_SKILLS stage using PUT commands
(printed by `deploy.sh`) or via Snowsight.

### 6. Deploy Streamlit App

```bash
cd .deploy_output/streamlit_app
snow streamlit deploy --replace
```

### 7. Verify

```sql
SHOW TABLES IN SCHEMA <your_db>.<your_schema>;          -- expect 19
SHOW VIEWS IN SCHEMA <your_db>.<your_schema>;           -- expect 6
SHOW SEMANTIC VIEWS IN SCHEMA <your_db>.<your_schema>;  -- expect 6
SHOW CORTEX SEARCH SERVICES IN SCHEMA <your_db>.<your_schema>; -- expect 1
SHOW AGENTS IN SCHEMA <your_db>.<your_schema>;          -- expect 5
LIST @<your_db>.<your_schema>.AGENT_SKILLS;             -- expect 5 files
```

## Architecture

SCM_ROUTER is the master orchestrator with 7 data tools + 5 domain skills.
It uses Cortex Analyst (text-to-SQL over semantic views) and Cortex Search
(unstructured supplier review documents). The 4 specialist agents are
parallel entry points sharing the same semantic views for consistent answers.

```
User → Streamlit App → SCM_ROUTER Agent
                            ├── procurement_skill + SCM_PROCUREMENT SV
                            ├── logistics_skill   + SCM_LOGISTICS SV
                            ├── demand_skill      + SV_DEMAND_FORECAST SV
                            ├── route_optimizer_skill + SV_GEOSPATIAL_DEMAND SV
                            └── supplier_review_skill + Cortex Search
```

## Directory Structure

```
SCM_DEPLOY/
├── config.env              # Edit this: DB, schema, warehouse names
├── deploy.sh               # Master deploy script
├── README.md               # This file
├── data/                   # CSV data + supplier review text docs
├── sql/                    # 10 ordered SQL deployment scripts
├── python/                 # Data generation + CSV loader scripts
├── cortex_project/         # Cortex project YAMLs (agents, SVs, skills)
├── streamlit_app/          # Streamlit-in-Snowflake app
└── docs/                   # Architecture diagrams + presentations
```
