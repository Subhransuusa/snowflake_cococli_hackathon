import streamlit as st
import altair as alt
import pandas as pd
from utils.connection import run_query


def render():
    # Inventory Health Summary
    st.subheader("Inventory Health Summary")
    df_inv = run_query("""
        SELECT INVENTORY_STATUS, COUNT(*) AS CNT
        FROM V_DAYS_OF_INVENTORY
        WHERE SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM V_DAYS_OF_INVENTORY)
        GROUP BY INVENTORY_STATUS
    """)
    if not df_inv.empty:
        status_map = {row["INVENTORY_STATUS"]: int(row["CNT"]) for _, row in df_inv.iterrows()}
        c1, c2, c3 = st.columns(3)
        c1.metric("Adequate", status_map.get("Adequate", 0))
        c2.metric("Reorder Required", status_map.get("Reorder Required", 0))
        c3.metric("Below Safety Stock", status_map.get("Below Safety Stock", 0))

        color_scale = alt.Scale(
            domain=["Adequate", "Reorder Required", "Below Safety Stock"],
            range=["#2E7D32", "#F57F17", "#C62828"],
        )
        pie = (
            alt.Chart(df_inv)
            .mark_arc()
            .encode(
                theta=alt.Theta("CNT:Q"),
                color=alt.Color("INVENTORY_STATUS:N", scale=color_scale, title="Status"),
                tooltip=["INVENTORY_STATUS:N", "CNT:Q"],
            )
            .properties(height=400)
        )
        st.altair_chart(pie, use_container_width=True)
    else:
        st.info("No inventory data available.")

    st.divider()

    # Fulfillment Performance
    st.subheader("Fulfillment Performance")
    df_fill = run_query("""
        SELECT PLANT_NAME, AVG(FILL_RATE_PCT) AS AVG_FILL_RATE
        FROM V_FILL_RATE
        WHERE ORDER_MONTH = (SELECT MAX(ORDER_MONTH) FROM V_FILL_RATE)
        GROUP BY PLANT_NAME
        ORDER BY AVG_FILL_RATE DESC
    """)
    if not df_fill.empty:
        avg_fill = df_fill["AVG_FILL_RATE"].mean()
        st.metric("Avg Fill Rate (Latest Month)", f"{avg_fill:.1f}%")

        chart = (
            alt.Chart(df_fill)
            .mark_bar()
            .encode(
                x=alt.X("PLANT_NAME:N", title="Plant", sort="-y"),
                y=alt.Y("AVG_FILL_RATE:Q", title="Avg Fill Rate %"),
                color=alt.Color(
                    "AVG_FILL_RATE:Q",
                    scale=alt.Scale(scheme="redyellowgreen"),
                    legend=None,
                ),
            )
            .properties(height=400)
        )
        text = chart.mark_text(dy=-8, fontSize=12).encode(
            text=alt.Text("AVG_FILL_RATE:Q", format=".1f")
        )
        st.altair_chart(chart + text, use_container_width=True)
    else:
        st.info("No fulfillment data for the latest month.")

    st.divider()

    # Logistics Performance
    st.subheader("Logistics Performance")
    df_ship = run_query("""
        SELECT CARRIER, AVG(DELIVERY_OTD_PCT) AS AVG_DELIVERY_OTD
        FROM V_SHIPMENT_OTD
        WHERE SHIP_MONTH = (SELECT MAX(SHIP_MONTH) FROM V_SHIPMENT_OTD)
        GROUP BY CARRIER
        ORDER BY AVG_DELIVERY_OTD DESC
    """)
    if not df_ship.empty:
        avg_otd = df_ship["AVG_DELIVERY_OTD"].mean()
        st.metric("Avg Delivery OTD (Latest Month)", f"{avg_otd:.1f}%")

        chart = (
            alt.Chart(df_ship)
            .mark_bar()
            .encode(
                x=alt.X("CARRIER:N", title="Carrier", sort="-y"),
                y=alt.Y("AVG_DELIVERY_OTD:Q", title="Delivery OTD %"),
                color=alt.Color(
                    "AVG_DELIVERY_OTD:Q",
                    scale=alt.Scale(scheme="redyellowgreen"),
                    legend=None,
                ),
            )
            .properties(height=400)
        )
        text = chart.mark_text(dy=-8, fontSize=12).encode(
            text=alt.Text("AVG_DELIVERY_OTD:Q", format=".1f")
        )
        st.altair_chart(chart + text, use_container_width=True)
    else:
        st.info("No logistics data for the latest month.")

    st.divider()

    # Cross-Domain Risk Matrix
    st.subheader("Cross-Domain Risk Matrix")
    st.caption("Parts that are BOTH below safety stock AND have fill rate < 90%")

    df_low_inv = run_query("""
        SELECT PLANT_ID, PLANT_NAME, PART_ID, PART_NAME, ON_HAND_QTY, SAFETY_STOCK_QTY, DAYS_OF_INVENTORY
        FROM V_DAYS_OF_INVENTORY
        WHERE SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM V_DAYS_OF_INVENTORY)
          AND INVENTORY_STATUS = 'Below Safety Stock'
    """)
    df_low_fill = run_query("""
        SELECT PLANT_ID, PLANT_NAME, CUSTOMER_NAME, FILL_RATE_PCT
        FROM V_FILL_RATE
        WHERE FILL_RATE_PCT < 90
    """)

    if not df_low_inv.empty and not df_low_fill.empty:
        risk = df_low_inv.merge(df_low_fill, on=["PLANT_ID", "PLANT_NAME"], how="inner")
        if not risk.empty:
            st.dataframe(risk, use_container_width=True)
        else:
            st.success("No parts currently flagged in both risk dimensions.")
    else:
        st.info("Insufficient data to compute cross-domain risk.")
