import streamlit as st
import altair as alt
import pandas as pd
from utils.connection import run_query


def render():
    # Fill Rate by Customer Segment
    st.subheader("Fill Rate by Customer Segment")
    df_seg = run_query("""
        SELECT SEGMENT, AVG(FILL_RATE_PCT) AS AVG_FILL_RATE
        FROM V_FILL_RATE
        GROUP BY SEGMENT
        ORDER BY AVG_FILL_RATE DESC
    """)
    if not df_seg.empty:
        chart = (
            alt.Chart(df_seg)
            .mark_bar()
            .encode(
                x=alt.X("SEGMENT:N", title="Customer Segment", sort="-y"),
                y=alt.Y("AVG_FILL_RATE:Q", title="Avg Fill Rate %"),
                color=alt.Color("SEGMENT:N", legend=None),
            )
            .properties(height=400)
        )
        text = chart.mark_text(dy=-8, fontSize=12).encode(
            text=alt.Text("AVG_FILL_RATE:Q", format=".1f")
        )
        st.altair_chart(chart + text, use_container_width=True)
    else:
        st.info("No fill rate data available.")

    st.divider()

    # Fill Rate Trend
    st.subheader("Fill Rate Trend")
    df_trend = run_query("""
        SELECT ORDER_MONTH, AVG(FILL_RATE_PCT) AS AVG_FILL_RATE
        FROM V_FILL_RATE
        GROUP BY ORDER_MONTH
        ORDER BY ORDER_MONTH
    """)
    if not df_trend.empty:
        line = (
            alt.Chart(df_trend)
            .mark_line(point=True, color="#0D47A1")
            .encode(
                x=alt.X("ORDER_MONTH:T", title="Month"),
                y=alt.Y("AVG_FILL_RATE:Q", title="Avg Fill Rate %"),
            )
            .properties(height=400)
        )
        st.altair_chart(line, use_container_width=True)
    else:
        st.info("No trend data available.")

    st.divider()

    # Order Fulfillment Detail
    st.subheader("Order Fulfillment Detail")
    df_detail = run_query("""
        SELECT CUSTOMER_NAME, SEGMENT, PLANT_NAME, ORDER_MONTH,
               TOTAL_ORDERED, TOTAL_FULFILLED, FILL_RATE_PCT
        FROM V_FILL_RATE
        ORDER BY ORDER_MONTH DESC, CUSTOMER_NAME
    """)
    if not df_detail.empty:
        segments = sorted(df_detail["SEGMENT"].unique().tolist())
        selected = st.multiselect("Filter by Segment", segments, default=segments)
        filtered = df_detail[df_detail["SEGMENT"].isin(selected)]
        st.dataframe(filtered, use_container_width=True)
    else:
        st.info("No fulfillment detail data available.")

    st.divider()

    # Customer Satisfaction Proxy
    st.subheader("Customer Satisfaction Proxy")
    st.caption("Fill Rate vs Delivery OTD per customer -- size = total orders, color = segment")

    df_fill = run_query("""
        SELECT CUSTOMER_ID, CUSTOMER_NAME, SEGMENT,
               AVG(FILL_RATE_PCT) AS AVG_FILL_RATE,
               SUM(TOTAL_ORDERED) AS TOTAL_ORDERS
        FROM V_FILL_RATE
        GROUP BY CUSTOMER_ID, CUSTOMER_NAME, SEGMENT
    """)
    df_otd = run_query("""
        SELECT CUSTOMER_ID,
               AVG(DELIVERY_OTD_PCT) AS AVG_DELIVERY_OTD
        FROM V_SHIPMENT_OTD
        GROUP BY CUSTOMER_ID
    """)

    if not df_fill.empty and not df_otd.empty:
        df_merged = df_fill.merge(df_otd, on="CUSTOMER_ID", how="inner")
        scatter = (
            alt.Chart(df_merged)
            .mark_circle()
            .encode(
                x=alt.X("AVG_FILL_RATE:Q", title="Avg Fill Rate %"),
                y=alt.Y("AVG_DELIVERY_OTD:Q", title="Avg Delivery OTD %"),
                size=alt.Size("TOTAL_ORDERS:Q", title="Total Orders"),
                color=alt.Color("SEGMENT:N"),
                tooltip=["CUSTOMER_NAME:N", "AVG_FILL_RATE:Q", "AVG_DELIVERY_OTD:Q", "TOTAL_ORDERS:Q", "SEGMENT:N"],
            )
            .properties(height=400)
        )
        st.altair_chart(scatter, use_container_width=True)
    else:
        st.info("Insufficient data to build the satisfaction proxy chart.")
