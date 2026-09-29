import streamlit as st
import altair as alt
import pandas as pd
from utils.connection import run_query

ACCENT = "#1B5E20"


def render():
    # Supplier Scorecard
    st.subheader("Supplier Scorecard")

    otd_df = run_query("""
        SELECT
            SUPPLIER_NAME,
            SUM(TOTAL_POS)   AS TOTAL_POS,
            SUM(ON_TIME_POS)  AS ON_TIME_POS,
            ROUND(SUM(ON_TIME_POS) * 100.0 / NULLIF(SUM(TOTAL_POS), 0), 1) AS OTD_PCT
        FROM V_ON_TIME_DELIVERY
        GROUP BY SUPPLIER_NAME
        ORDER BY OTD_PCT ASC
    """)

    if otd_df.empty:
        st.info("No on-time delivery data available.")
    else:
        otd_display = otd_df.copy()
        otd_display["Status"] = otd_display["OTD_PCT"].apply(
            lambda v: "PASS" if v >= 95 else ("WARN" if v >= 90 else "FAIL")
        )
        otd_display = otd_display.rename(columns={
            "SUPPLIER_NAME": "Supplier",
            "TOTAL_POS": "Total POs",
            "ON_TIME_POS": "On-Time POs",
            "OTD_PCT": "OTD %",
        })
        st.dataframe(otd_display[["Supplier", "Total POs", "On-Time POs", "OTD %", "Status"]],
                     use_container_width=True)

    st.divider()

    # Landed Cost Waterfall
    st.subheader("Landed Cost Breakdown")

    cost_df = run_query("""
        SELECT
            ORDER_MONTH,
            AVG(MATERIAL_COST)  AS AVG_MATERIAL,
            AVG(FREIGHT_COST)   AS AVG_FREIGHT,
            AVG(DUTY_COST)      AS AVG_DUTY,
            AVG(HANDLING_COST)   AS AVG_HANDLING
        FROM V_LANDED_COST
        GROUP BY ORDER_MONTH
        ORDER BY ORDER_MONTH ASC
    """)

    if cost_df.empty:
        st.info("No landed-cost data available.")
    else:
        cost_long = cost_df.melt(
            id_vars=["ORDER_MONTH"],
            value_vars=["AVG_MATERIAL", "AVG_FREIGHT", "AVG_DUTY", "AVG_HANDLING"],
            var_name="Cost Component",
            value_name="Avg Cost",
        )
        label_map = {
            "AVG_MATERIAL": "Material",
            "AVG_FREIGHT": "Freight",
            "AVG_DUTY": "Duty",
            "AVG_HANDLING": "Handling",
        }
        color_map = {
            "Material": "#1B5E20",
            "Freight": "#E65100",
            "Duty": "#0D47A1",
            "Handling": "#6A1B9A",
        }
        cost_long["Cost Component"] = cost_long["Cost Component"].map(label_map)

        chart_cost = (
            alt.Chart(cost_long)
            .mark_bar()
            .encode(
                x=alt.X("ORDER_MONTH:N", title="Month"),
                y=alt.Y("Avg Cost:Q", title="Avg Cost ($)", stack="zero"),
                color=alt.Color(
                    "Cost Component:N",
                    scale=alt.Scale(domain=list(color_map.keys()), range=list(color_map.values())),
                ),
                tooltip=[
                    alt.Tooltip("ORDER_MONTH:N", title="Month"),
                    alt.Tooltip("Cost Component:N"),
                    alt.Tooltip("Avg Cost:Q", format="$.2f"),
                ],
            )
            .properties(width="container", height=420)
        )
        st.altair_chart(chart_cost, use_container_width=True)

    st.divider()

    # PPV by Category
    st.subheader("PPV by Category")

    ppv_df = run_query("""
        SELECT
            PART_NAME,
            AVG(LANDED_COST_PER_UNIT) AS AVG_LANDED_COST
        FROM V_LANDED_COST
        GROUP BY PART_NAME
        ORDER BY AVG_LANDED_COST DESC
    """)

    if ppv_df.empty:
        st.info("No landed-cost data available for PPV analysis.")
    else:
        chart_ppv = (
            alt.Chart(ppv_df)
            .mark_bar(color="#26A69A")
            .encode(
                x=alt.X("AVG_LANDED_COST:Q", title="Avg Landed Cost / Unit ($)"),
                y=alt.Y("PART_NAME:N", title="Part Category", sort="-x"),
                tooltip=[
                    alt.Tooltip("PART_NAME:N", title="Part"),
                    alt.Tooltip("AVG_LANDED_COST:Q", title="Avg Cost", format="$.2f"),
                ],
            )
            .properties(width="container", height=max(300, len(ppv_df) * 35))
        )
        st.altair_chart(chart_ppv, use_container_width=True)

    st.divider()

    # SLA Breach List
    st.subheader("SLA Breach List")

    breach_df = run_query("""
        SELECT
            SUPPLIER_NAME,
            ORDER_MONTH,
            OTD_PCT,
            TOTAL_POS
        FROM V_ON_TIME_DELIVERY
        WHERE OTD_PCT < 90
        ORDER BY OTD_PCT ASC
    """)

    if breach_df.empty:
        st.info("No SLA breaches detected -- all suppliers above 90% threshold.")
    else:
        breach_display = breach_df.rename(columns={
            "SUPPLIER_NAME": "Supplier",
            "ORDER_MONTH": "Month",
            "OTD_PCT": "OTD %",
            "TOTAL_POS": "Total POs",
        })
        st.dataframe(breach_display, use_container_width=True)
