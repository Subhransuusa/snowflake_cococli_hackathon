#!/usr/bin/env bash
# ============================================================
# SCM Analytics Platform — Master Deployment Script
# ============================================================
# Usage:
#   1. Edit config.env with your database, schema, and warehouse names
#   2. Run: bash deploy.sh [--dry-run]
#
# Options:
#   --dry-run   Generate resolved SQL files in .deploy_output/ without executing
#   --help      Show this help message
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.env"
OUTPUT_DIR="${SCRIPT_DIR}/.deploy_output"

# ── Parse arguments ──────────────────────────────────────────
DRY_RUN=false
for arg in "$@"; do
  case $arg in
    --dry-run)  DRY_RUN=true ;;
    --help|-h)
      head -12 "$0" | tail -8
      exit 0
      ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

# ── Load configuration ───────────────────────────────────────
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: config.env not found at $CONFIG_FILE"
  echo "Copy config.env.example to config.env and edit it."
  exit 1
fi

source "$CONFIG_FILE"

echo "============================================================"
echo "  SCM Analytics Platform Deployment"
echo "============================================================"
echo "  Database:   ${SF_DATABASE}"
echo "  Schema:     ${SF_SCHEMA}"
echo "  Warehouse:  ${SF_WAREHOUSE}"
echo "  Mode:       $(if $DRY_RUN; then echo 'DRY RUN (generate only)'; else echo 'LIVE'; fi)"
echo "============================================================"
echo ""

# ── Create output directory ──────────────────────────────────
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/sql"
mkdir -p "$OUTPUT_DIR/cortex_project/skills"
mkdir -p "$OUTPUT_DIR/streamlit_app"
mkdir -p "$OUTPUT_DIR/python"

# ── Substitution function ────────────────────────────────────
resolve_placeholders() {
  local src="$1"
  local dst="$2"
  sed \
    -e "s|__SF_DATABASE__|${SF_DATABASE}|g" \
    -e "s|__SF_SCHEMA__|${SF_SCHEMA}|g" \
    -e "s|__SF_WAREHOUSE__|${SF_WAREHOUSE}|g" \
    "$src" > "$dst"
}

# ── Resolve SQL files ────────────────────────────────────────
echo "[1/5] Resolving SQL files..."
for f in "$SCRIPT_DIR"/sql/*.sql; do
  fname=$(basename "$f")
  resolve_placeholders "$f" "$OUTPUT_DIR/sql/$fname"
  echo "      $fname"
done

# ── Resolve Cortex Project files ─────────────────────────────
echo "[2/5] Resolving Cortex Project files (agents + semantic views)..."
for f in "$SCRIPT_DIR"/cortex_project/*.yaml; do
  fname=$(basename "$f")
  resolve_placeholders "$f" "$OUTPUT_DIR/cortex_project/$fname"
  echo "      $fname"
done

# Copy skill files as-is
cp -r "$SCRIPT_DIR"/cortex_project/skills/ "$OUTPUT_DIR/cortex_project/skills/"
echo "      skills/ (copied)"

# ── Resolve Streamlit app ────────────────────────────────────
echo "[3/5] Resolving Streamlit app..."
# Copy entire app first
cp -r "$SCRIPT_DIR"/streamlit_app/* "$OUTPUT_DIR/streamlit_app/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/streamlit_app/.streamlit "$OUTPUT_DIR/streamlit_app/" 2>/dev/null || true
# Resolve all files that may contain placeholders
while IFS= read -r f; do
  resolve_placeholders "$f" "${f}.tmp"
  mv "${f}.tmp" "$f"
  echo "      $(realpath --relative-to="$OUTPUT_DIR/streamlit_app" "$f")"
done < <(grep -rl '__SF_DATABASE__\|__SF_SCHEMA__\|__SF_WAREHOUSE__' "$OUTPUT_DIR/streamlit_app/" 2>/dev/null || true)

# ── Resolve Python scripts ───────────────────────────────────
echo "[4/5] Resolving Python scripts..."
for f in "$SCRIPT_DIR"/python/*.py; do
  fname=$(basename "$f")
  resolve_placeholders "$f" "$OUTPUT_DIR/python/$fname"
  echo "      $fname"
done

echo "[5/5] All files resolved to: $OUTPUT_DIR/"
echo ""

# ── Deployment instructions ──────────────────────────────────
if $DRY_RUN; then
  echo "DRY RUN complete. Resolved files are in:"
  echo "  $OUTPUT_DIR/"
  echo ""
  echo "Verify the output, then re-run without --dry-run to deploy."
  exit 0
fi

echo "============================================================"
echo "  DEPLOYMENT STEPS"
echo "============================================================"
echo ""
echo "Run the following SQL files in order using your preferred"
echo "Snowflake client (Snowsight, SnowSQL, or cortex CLI)."
echo "All resolved files are in: $OUTPUT_DIR/sql/"
echo ""
echo "  Step 1:  01_database_schema.sql          (Create DB + schema)"
echo "  Step 2:  02_core_entity_tables.sql        (11 core tables)"
echo "  Step 3:  03_geospatial_tables.sql         (7 geo/trend tables)"
echo "  Step 4:  04_supplier_review_docs_table.sql (Docs table)"
echo "  Step 5:  05_core_data.sql                 (Load synthetic data)"
echo "  Step 6:  06_metric_views.sql              (6 metric views)"
echo "  Step 7:  07_deploy_semantic_views.sql     (6 semantic views)"
echo "  Step 8:  08_cortex_search_service.sql     (Cortex Search)"
echo "  Step 9:  09_deploy_agents.sql             (5 Cortex Agents)"
echo "  Step 10: 10_governance_tables.sql         (Governance tables)"
echo ""
echo "  Then load CSV data:"
echo "    python $OUTPUT_DIR/python/generate_data.py"
echo "    python $OUTPUT_DIR/python/load_csv_to_snowflake.py"
echo ""
echo "  Upload agent skill files to the stage:"
echo "    PUT file://$OUTPUT_DIR/cortex_project/skills/procurement_skill/SKILL.md"
echo "        @${SF_DATABASE}.${SF_SCHEMA}.AGENT_SKILLS/skills/procurement_skill/ AUTO_COMPRESS=FALSE;"
echo "    PUT file://$OUTPUT_DIR/cortex_project/skills/logistics_skill/SKILL.md"
echo "        @${SF_DATABASE}.${SF_SCHEMA}.AGENT_SKILLS/skills/logistics_skill/ AUTO_COMPRESS=FALSE;"
echo "    PUT file://$OUTPUT_DIR/cortex_project/skills/demand_skill/SKILL.md"
echo "        @${SF_DATABASE}.${SF_SCHEMA}.AGENT_SKILLS/skills/demand_skill/ AUTO_COMPRESS=FALSE;"
echo "    PUT file://$OUTPUT_DIR/cortex_project/skills/supplier_review_skill/SKILL.md"
echo "        @${SF_DATABASE}.${SF_SCHEMA}.AGENT_SKILLS/skills/supplier_review_skill/ AUTO_COMPRESS=FALSE;"
echo "    PUT file://$OUTPUT_DIR/cortex_project/skills/route_optimizer_skill/SKILL.md"
echo "        @${SF_DATABASE}.${SF_SCHEMA}.AGENT_SKILLS/skills/route_optimizer_skill/ AUTO_COMPRESS=FALSE;"
echo ""
echo "  Deploy Streamlit app:"
echo "    cd $OUTPUT_DIR/streamlit_app"
echo "    snow streamlit deploy --replace"
echo ""
echo "  VERIFICATION:"
echo "    SHOW TABLES IN SCHEMA ${SF_DATABASE}.${SF_SCHEMA};"
echo "    SHOW VIEWS IN SCHEMA ${SF_DATABASE}.${SF_SCHEMA};"
echo "    SHOW SEMANTIC VIEWS IN SCHEMA ${SF_DATABASE}.${SF_SCHEMA};"
echo "    SHOW CORTEX SEARCH SERVICES IN SCHEMA ${SF_DATABASE}.${SF_SCHEMA};"
echo "    SHOW AGENTS IN SCHEMA ${SF_DATABASE}.${SF_SCHEMA};"
echo "    LIST @${SF_DATABASE}.${SF_SCHEMA}.AGENT_SKILLS;"
echo ""
echo "  Expected counts:"
echo "    Tables:          19"
echo "    Views:            6"
echo "    Semantic Views:   6"
echo "    Cortex Search:    1"
echo "    Agents:           5"
echo "    Stage files:      5"
echo ""
echo "============================================================"
