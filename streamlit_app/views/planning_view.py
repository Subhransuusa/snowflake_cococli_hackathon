import streamlit as st
import pandas as pd
import altair as alt
from utils.connection import run_query


def render():
    # Days of Inventory by Plant & Category
    st.subheader("Days of Inventory by Plant & Category")

    df_doi = run_query("""
        SELECT PLANT_NAME, CATEGORY,
               ROUND(AVG(DAYS_OF_INVENTORY), 1) AS AVG_DOI,
               SUM(ON_HAND_QTY) AS TOTAL_ON_HAND,
               SUM(SAFETY_STOCK_QTY) AS TOTAL_SAFETY_STOCK
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_DAYS_OF_INVENTORY
        WHERE SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM __SF_DATABASE__.__SF_SCHEMA__.V_DAYS_OF_INVENTORY)
        GROUP BY PLANT_NAME, CATEGORY
        ORDER BY PLANT_NAME, CATEGORY
    """)

    if df_doi.empty:
        st.info("No inventory data available.")
    else:
        chart_doi = (
            alt.Chart(df_doi)
            .mark_bar()
            .encode(
                x=alt.X("PLANT_NAME:N", title="Plant"),
                y=alt.Y("AVG_DOI:Q", title="Avg Days of Inventory"),
                color=alt.Color("CATEGORY:N", legend=alt.Legend(title="Category")),
                column=alt.Column("CATEGORY:N", header=alt.Header(labelOrient="bottom", title=None)),
                tooltip=["PLANT_NAME", "CATEGORY", alt.Tooltip("AVG_DOI:Q", format=".0f")],
            )
            .properties(width=120, height=400, title="Avg Days of Inventory by Plant & Category")
        )
        st.altair_chart(
            chart_doi,
            use_container_width=True,
        )

        st.markdown("**Avg DOI per Plant**")
        plant_avg = df_doi.groupby("PLANT_NAME")["AVG_DOI"].mean().reset_index()
        plant_avg.columns = ["Plant", "Avg Days of Inventory"]
        plant_avg["Avg Days of Inventory"] = plant_avg["Avg Days of Inventory"].round(1)
        st.dataframe(plant_avg, use_container_width=True)

    st.divider()

    # Weeks of Cover
    st.subheader("Weeks of Cover")

    if df_doi.empty:
        st.info("No inventory data available for weeks of cover.")
    else:
        df_woc = df_doi.copy()
        df_woc["WEEKS_OF_COVER"] = (df_woc["AVG_DOI"] / 7).round(1)

        heatmap_data = df_woc.groupby(["PLANT_NAME", "CATEGORY"])["WEEKS_OF_COVER"].mean().reset_index()

        chart_woc = (
            alt.Chart(heatmap_data)
            .mark_rect()
            .encode(
                x=alt.X("CATEGORY:N", title="Category"),
                y=alt.Y("PLANT_NAME:N", title="Plant"),
                color=alt.Color(
                    "WEEKS_OF_COVER:Q",
                    scale=alt.Scale(scheme="redyellowgreen"),
                    legend=alt.Legend(title="Weeks of Cover"),
                ),
                tooltip=["PLANT_NAME", "CATEGORY", alt.Tooltip("WEEKS_OF_COVER:Q", format=".1f")],
            )
        )
        text_woc = (
            alt.Chart(heatmap_data)
            .mark_text(fontSize=11)
            .encode(
                x=alt.X("CATEGORY:N"),
                y=alt.Y("PLANT_NAME:N"),
                text=alt.Text("WEEKS_OF_COVER:Q", format=".1f"),
                color=alt.condition(
                    alt.datum.WEEKS_OF_COVER > heatmap_data["WEEKS_OF_COVER"].median(),
                    alt.value("black"),
                    alt.value("white"),
                ),
            )
        )
        st.altair_chart(
            (chart_woc + text_woc).properties(
                title="Weeks of Cover: Plant x Category", height=450
            ),
            use_container_width=True,
        )

    st.divider()

    # Stockout Risk Top-N
    st.subheader("Stockout Risk Top-N")

    top_n = st.slider("Show top N at-risk items", min_value=5, max_value=50, value=10, step=5)

    df_stockout = run_query(f"""
        SELECT PLANT_NAME, PART_NAME, CATEGORY,
               ON_HAND_QTY, SAFETY_STOCK_QTY, AVG_DAILY_USAGE,
               DAYS_OF_INVENTORY, INVENTORY_STATUS
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_DAYS_OF_INVENTORY
        WHERE INVENTORY_STATUS = 'Below Safety Stock'
          AND SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM __SF_DATABASE__.__SF_SCHEMA__.V_DAYS_OF_INVENTORY)
        ORDER BY DAYS_OF_INVENTORY ASC
        LIMIT {top_n}
    """)

    if df_stockout.empty:
        st.success("No items currently below safety stock.")
    else:
        def highlight_critical(row):
            if row["DAYS_OF_INVENTORY"] is not None and row["DAYS_OF_INVENTORY"] < 5:
                return ["background-color: #ffcccc"] * len(row)
            return [""] * len(row)

        styled = df_stockout.style.apply(highlight_critical, axis=1)
        st.dataframe(styled, use_container_width=True)

        st.caption(f"Showing top {len(df_stockout)} items below safety stock, sorted by days of inventory (ascending). Rows highlighted in red have < 5 days of inventory.")

    st.divider()

    # Forecast vs Actual with Error Bands
    st.subheader("Forecast vs Actual with Error Bands")

    categories = run_query("""
        SELECT DISTINCT CATEGORY
        FROM __SF_DATABASE__.__SF_SCHEMA__.MARKET_TRENDS
        ORDER BY CATEGORY
    """)

    if categories.empty:
        st.info("No market trends data available.")
    else:
        selected_category = st.selectbox("Select Category", categories["CATEGORY"].tolist())

        df_forecast = run_query(f"""
            SELECT WEEK_DATE,
                   SUM(DEMAND_UNITS) AS DEMAND_UNITS,
                   SUM(FORECAST_UNITS) AS FORECAST_UNITS
            FROM __SF_DATABASE__.__SF_SCHEMA__.MARKET_TRENDS
            WHERE CATEGORY = '{selected_category}'
            GROUP BY WEEK_DATE
            ORDER BY WEEK_DATE
        """)

        if df_forecast.empty:
            st.info(f"No forecast data available for {selected_category}.")
        else:
            df_forecast["FORECAST_UPPER"] = (df_forecast["FORECAST_UNITS"] * 1.10).round(0)
            df_forecast["FORECAST_LOWER"] = (df_forecast["FORECAST_UNITS"] * 0.90).round(0)

            band = (
                alt.Chart(df_forecast)
                .mark_area(opacity=0.3, color="#90CAF9")
                .encode(
                    x=alt.X("WEEK_DATE:T", title="Week"),
                    y=alt.Y("FORECAST_LOWER:Q", title="Units"),
                    y2="FORECAST_UPPER:Q",
                )
            )

            line_forecast = (
                alt.Chart(df_forecast)
                .mark_line(strokeDash=[5, 5], color="#1565C0")
                .encode(x="WEEK_DATE:T", y="FORECAST_UNITS:Q")
            )

            line_actual = (
                alt.Chart(df_forecast)
                .mark_line(point=True, color="#D32F2F")
                .encode(x="WEEK_DATE:T", y="DEMAND_UNITS:Q")
            )

            combined = (
                (band + line_forecast + line_actual)
                .properties(
                    title=f"Forecast vs Actual Demand -- {selected_category}",
                    height=500,
                )
            )
            st.altair_chart(combined, use_container_width=True)

            st.markdown(
                "**Forecast** (dashed blue) | **Actual Demand** (red) | **+/-10% Error Band** (shaded)"
            )

            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Avg Actual Demand", f"{df_forecast['DEMAND_UNITS'].mean():,.0f}")
            with col2:
                st.metric("Avg Forecast", f"{df_forecast['FORECAST_UNITS'].mean():,.0f}")
            with col3:
                mape = (abs(df_forecast["DEMAND_UNITS"] - df_forecast["FORECAST_UNITS"]) / df_forecast["DEMAND_UNITS"].replace(0, 1)).mean() * 100
                st.metric("MAPE", f"{mape:.1f}%")
