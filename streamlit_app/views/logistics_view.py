import streamlit as st
import pandas as pd
import altair as alt
from utils.connection import run_query


def render():
    # OTD by Carrier
    st.subheader("OTD by Carrier")

    df_otd = run_query("""
        SELECT CARRIER,
               SUM(TOTAL_SHIPMENTS) AS TOTAL_SHIPMENTS,
               SUM(ON_TIME_DELIVERIES) AS ON_TIME_DELIVERIES,
               ROUND(SUM(ON_TIME_DELIVERIES) * 100.0 / NULLIF(SUM(TOTAL_SHIPMENTS), 0), 2) AS DELIVERY_OTD_PCT
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_SHIPMENT_OTD
        GROUP BY CARRIER
        ORDER BY DELIVERY_OTD_PCT DESC
    """)

    if df_otd.empty:
        st.info("No shipment OTD data available.")
    else:
        chart_otd = (
            alt.Chart(df_otd)
            .mark_bar()
            .encode(
                x=alt.X("CARRIER:N", title="Carrier", sort="-y"),
                y=alt.Y("DELIVERY_OTD_PCT:Q", title="OTD %", scale=alt.Scale(domain=[0, 105])),
                color=alt.Color(
                    "DELIVERY_OTD_PCT:Q",
                    scale=alt.Scale(scheme="redyellowgreen"),
                    legend=alt.Legend(title="OTD %"),
                ),
            )
        )
        text_otd = chart_otd.mark_text(dy=-10).encode(
            text=alt.Text("DELIVERY_OTD_PCT:Q", format=".1f"),
        )
        st.altair_chart(
            (chart_otd + text_otd).properties(title="On-Time Delivery % by Carrier", height=400),
            use_container_width=True,
        )

    st.divider()

    # Lane Heatmap
    st.subheader("Lane Heatmap (Origin x Destination)")

    df_routes = run_query("""
        SELECT PLANT_NAME,
               SUPPLIER_NAME,
               TRADE_LANE,
               COUNT(*) AS ROUTE_COUNT,
               ROUND(AVG(EST_COST_USD), 2) AS AVG_COST_USD,
               RISK_LEVEL
        FROM __SF_DATABASE__.__SF_SCHEMA__.SHIPPING_ROUTES
        GROUP BY PLANT_NAME, SUPPLIER_NAME, TRADE_LANE, RISK_LEVEL
        ORDER BY AVG_COST_USD DESC
    """)

    if df_routes.empty:
        st.info("No shipping route data available.")
    else:
        heatmap_data = (
            df_routes.groupby(["PLANT_NAME", "SUPPLIER_NAME"])["AVG_COST_USD"]
            .mean()
            .reset_index()
        )

        chart_heatmap = (
            alt.Chart(heatmap_data)
            .mark_rect()
            .encode(
                x=alt.X("SUPPLIER_NAME:N", title="Supplier (Destination)"),
                y=alt.Y("PLANT_NAME:N", title="Plant (Origin)"),
                color=alt.Color(
                    "AVG_COST_USD:Q",
                    scale=alt.Scale(scheme="yelloworangered"),
                    legend=alt.Legend(title="Avg Cost USD"),
                ),
                tooltip=["PLANT_NAME", "SUPPLIER_NAME", alt.Tooltip("AVG_COST_USD:Q", format=",.2f")],
            )
        )
        text_heatmap = (
            alt.Chart(heatmap_data)
            .mark_text(fontSize=11)
            .encode(
                x=alt.X("SUPPLIER_NAME:N"),
                y=alt.Y("PLANT_NAME:N"),
                text=alt.Text("AVG_COST_USD:Q", format=",.0f"),
                color=alt.condition(
                    alt.datum.AVG_COST_USD > heatmap_data["AVG_COST_USD"].median(),
                    alt.value("white"),
                    alt.value("black"),
                ),
            )
        )
        st.altair_chart(
            (chart_heatmap + text_heatmap).properties(
                title="Avg Shipping Cost (USD): Origin Plant vs Supplier", height=500
            ),
            use_container_width=True,
        )

        with st.expander("Route Details Table"):
            st.dataframe(df_routes, use_container_width=True)

    st.divider()

    # Transit Days Distribution
    st.subheader("Transit Performance by Mode")

    df_transit = run_query("""
        SELECT TRANSPORT_MODE,
               COUNT(*) AS SHIPMENT_COUNT,
               SUM(TOTAL_SHIPMENTS) AS TOTAL_SHIPMENTS,
               ROUND(AVG(DELIVERY_OTD_PCT), 2) AS AVG_OTD_PCT,
               SUM(ON_TIME_DELIVERIES) AS ON_TIME_DELIVERIES
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_SHIPMENT_OTD
        GROUP BY TRANSPORT_MODE
        ORDER BY TRANSPORT_MODE
    """)

    if df_transit.empty:
        st.info("No transit data available.")
    else:
        chart_transit = (
            alt.Chart(df_transit)
            .mark_bar()
            .encode(
                x=alt.X("TRANSPORT_MODE:N", title="Transport Mode"),
                y=alt.Y("AVG_OTD_PCT:Q", title="Avg OTD %", scale=alt.Scale(domain=[0, 105])),
                color=alt.Color("TRANSPORT_MODE:N", legend=None),
            )
        )
        text_transit = chart_transit.mark_text(dy=-10).encode(
            text=alt.Text("AVG_OTD_PCT:Q", format=".1f"),
        )
        st.altair_chart(
            (chart_transit + text_transit).properties(
                title="Avg On-Time Delivery % by Transport Mode", height=400
            ),
            use_container_width=True,
        )

        col1, col2 = st.columns(2)
        with col1:
            st.metric("Total Shipment Groups", int(df_transit["SHIPMENT_COUNT"].sum()))
        with col2:
            st.metric("Overall Avg OTD %", f"{df_transit['AVG_OTD_PCT'].mean():.1f}%")
