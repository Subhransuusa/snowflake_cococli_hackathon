import streamlit as st
import pandas as pd
from utils.connection import run_query


def render():
    # NL Consistency Test Results
    st.subheader("NL Consistency Test Results")
    try:
        df_nl = run_query("SELECT * FROM NL_CONSISTENCY_RESULTS ORDER BY TEST_ID")
        if not df_nl.empty:
            total = len(df_nl)
            passed = len(df_nl[df_nl["STATUS"] == "PASS"])
            pass_rate = passed / total * 100

            c1, c2, c3 = st.columns(3)
            c1.metric("Pass Rate", f"{pass_rate:.1f}%")
            c2.metric("Passed", passed)
            c3.metric("Total Tests", total)

            def highlight_status(row):
                color = "#C8E6C9" if row["STATUS"] == "PASS" else "#FFCDD2"
                return [f"background-color: {color}"] * len(row)

            st.dataframe(
                df_nl.style.apply(highlight_status, axis=1),
                use_container_width=True,
            )
        else:
            st.info("No test results found.")
    except Exception:
        st.warning(
            "NL_CONSISTENCY_RESULTS table not found. "
            "Run the consistency test setup SQL to populate this table."
        )

    st.divider()

    # Metric Dictionary
    st.subheader("Metric Dictionary")
    try:
        df_rules = run_query("""
            SELECT RULE_ID, METRIC_NAME, DOMAIN, DEFINITION, FORMULA, UNIT, TARGET, SEMANTIC_VIEW
            FROM BUSINESS_RULES
            ORDER BY DOMAIN, RULE_ID
        """)
        if not df_rules.empty:
            st.dataframe(df_rules, use_container_width=True)
        else:
            st.info("No business rules found.")
    except Exception:
        st.warning(
            "BUSINESS_RULES table not found. "
            "Run the governance setup SQL to create and populate this table."
        )

    st.divider()

    # Ontology Overview
    st.subheader("Ontology Overview")
    st.code("""
SUPPLIERS ---+
             +--- SUPPLIER_PARTS --- PARTS ---+
             |                                 +--- PURCHASE_ORDERS
PLANTS ------+                                 +--- PLANT_INVENTORY
  |                                            +--- ORDER_LINES --- SALES_ORDERS --- CUSTOMERS
  +--- SHIPMENTS --- SHIPMENT_LINES            |
  +--- SHIPPING_ROUTES                         +--- DEMAND_FORECAST
                                                    MARKET_TRENDS
""", language=None)

    st.divider()

    # Data Access Policies
    st.subheader("Data Access Policies")
    st.caption("Summary of semantic view governance and persona-based access")

    access_data = [
        {"Semantic View": "SV_PROCUREMENT", "Domain": "Procurement", "Personas": "Procurement, Executive", "Governed": "Yes"},
        {"Semantic View": "SV_INVENTORY", "Domain": "Inventory", "Personas": "Inventory Planner, Executive", "Governed": "Yes"},
        {"Semantic View": "SV_LOGISTICS", "Domain": "Logistics", "Personas": "Logistics, Executive", "Governed": "Yes"},
        {"Semantic View": "SV_SALES", "Domain": "Sales", "Personas": "Sales, Executive", "Governed": "Yes"},
        {"Semantic View": "SV_DEMAND_FORECAST", "Domain": "Demand", "Personas": "Inventory Planner, Sales, Executive", "Governed": "Yes"},
        {"Semantic View": "SV_EXECUTIVE_SUMMARY", "Domain": "Cross-domain", "Personas": "Executive", "Governed": "Yes"},
    ]
    df_access = pd.DataFrame(access_data)
    st.dataframe(df_access, use_container_width=True)
