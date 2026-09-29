import streamlit as st
import altair as alt
import pandas as pd
from utils.connection import run_query

ACCENT = "#0D47A1"


def render():
    exec_df = run_query("SELECT * FROM V_SCM_EXECUTIVE_SUMMARY ORDER BY PERIOD ASC")

    if exec_df.empty:
        st.warning("No executive summary data available.")
        return

    latest = exec_df.iloc[-1]
    prior = exec_df.iloc[-2] if len(exec_df) >= 2 else None

    def _delta(current, previous):
        if previous is None or pd.isna(previous):
            return None
        return round(float(current) - float(previous), 2)

    try:
        risk_df = run_query("""
            SELECT COUNT(*) AS CNT
            FROM V_DAYS_OF_INVENTORY
            WHERE INVENTORY_STATUS = 'Below Safety Stock'
              AND SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM V_DAYS_OF_INVENTORY)
        """)
        open_risk = int(risk_df["CNT"].iloc[0]) if not risk_df.empty else 0
    except Exception:
        open_risk = 0

    try:
        risk_prior_df = run_query("""
            SELECT COUNT(*) AS CNT
            FROM V_DAYS_OF_INVENTORY
            WHERE INVENTORY_STATUS = 'Below Safety Stock'
              AND SNAPSHOT_DATE = (
                  SELECT MAX(SNAPSHOT_DATE) FROM V_DAYS_OF_INVENTORY
                  WHERE SNAPSHOT_DATE < (SELECT MAX(SNAPSHOT_DATE) FROM V_DAYS_OF_INVENTORY)
              )
        """)
        risk_prior = int(risk_prior_df["CNT"].iloc[0]) if not risk_prior_df.empty else None
    except Exception:
        risk_prior = None

    def _get_rule(metric_name: str) -> str:
        try:
            rule_df = run_query(
                f"SELECT DEFINITION FROM BUSINESS_RULES WHERE METRIC_NAME = '{metric_name}' LIMIT 1"
            )
            if not rule_df.empty:
                return str(rule_df.iloc[0, 0])
        except Exception:
            pass
        return "No business rule defined yet."

    tile_defs = [
        {
            "label": "Supplier OTD %",
            "value": f"{latest['AVG_SUPPLIER_OTD']:.1f}%",
            "delta": _delta(latest["AVG_SUPPLIER_OTD"], prior["AVG_SUPPLIER_OTD"] if prior is not None else None),
            "delta_color": "normal",
            "rule_key": "SUPPLIER_OTD_PCT",
        },
        {
            "label": "Fill Rate %",
            "value": f"{latest['AVG_FILL_RATE']:.1f}%",
            "delta": _delta(latest["AVG_FILL_RATE"], prior["AVG_FILL_RATE"] if prior is not None else None),
            "delta_color": "normal",
            "rule_key": "FILL_RATE_PCT",
        },
        {
            "label": "Days of Inventory",
            "value": f"{latest['AVG_DAYS_OF_INVENTORY']:.1f}",
            "delta": _delta(latest["AVG_DAYS_OF_INVENTORY"], prior["AVG_DAYS_OF_INVENTORY"] if prior is not None else None),
            "delta_color": "inverse",
            "rule_key": "DAYS_OF_INVENTORY",
        },
        {
            "label": "Landed Cost / Unit",
            "value": f"${latest['AVG_LANDED_COST_PER_UNIT']:.2f}",
            "delta": _delta(latest["AVG_LANDED_COST_PER_UNIT"], prior["AVG_LANDED_COST_PER_UNIT"] if prior is not None else None),
            "delta_color": "inverse",
            "rule_key": "LANDED_COST_PER_UNIT",
        },
        {
            "label": "Delivery OTD %",
            "value": f"{latest['AVG_DELIVERY_OTD']:.1f}%",
            "delta": _delta(latest["AVG_DELIVERY_OTD"], prior["AVG_DELIVERY_OTD"] if prior is not None else None),
            "delta_color": "normal",
            "rule_key": "DELIVERY_OTD_PCT",
        },
        {
            "label": "Open Risk Signals",
            "value": str(open_risk),
            "delta": _delta(open_risk, risk_prior),
            "delta_color": "inverse",
            "rule_key": "OPEN_RISK_SIGNALS",
        },
    ]

    row1 = st.columns(3)
    for col, tile in zip(row1, tile_defs[:3]):
        with col:
            delta_str = f"{tile['delta']:+.2f}" if tile["delta"] is not None else None
            st.metric(label=tile["label"], value=tile["value"], delta=delta_str, delta_color=tile["delta_color"])
            with st.expander("Rule"):
                st.markdown(_get_rule(tile["rule_key"]))

    row2 = st.columns(3)
    for col, tile in zip(row2, tile_defs[3:]):
        with col:
            delta_str = f"{tile['delta']:+.2f}" if tile["delta"] is not None else None
            st.metric(label=tile["label"], value=tile["value"], delta=delta_str, delta_color=tile["delta_color"])
            with st.expander("Rule"):
                st.markdown(_get_rule(tile["rule_key"]))

    st.divider()
    st.subheader("KPI Trends Over Time")

    metric_cols = [
        ("AVG_SUPPLIER_OTD", "Supplier OTD %"),
        ("AVG_FILL_RATE", "Fill Rate %"),
        ("AVG_DAYS_OF_INVENTORY", "Days of Inventory"),
        ("AVG_LANDED_COST_PER_UNIT", "Landed Cost/Unit"),
        ("AVG_DELIVERY_OTD", "Delivery OTD %"),
    ]

    trend_rows = []
    for col_name, display_name in metric_cols:
        series = pd.to_numeric(exec_df[col_name], errors="coerce")
        s_min, s_max = series.min(), series.max()
        if s_max != s_min:
            normalized = ((series - s_min) / (s_max - s_min)) * 100
        else:
            normalized = series * 0 + 50
        for period, val in zip(exec_df["PERIOD"], normalized):
            trend_rows.append({"Period": period, "Normalized": round(val, 2), "Metric": display_name})

    trend_df = pd.DataFrame(trend_rows)

    chart_trend = (
        alt.Chart(trend_df)
        .mark_line(point=True)
        .encode(
            x=alt.X("Period:N", title="Period"),
            y=alt.Y("Normalized:Q", title="Normalized (0-100)"),
            color=alt.Color("Metric:N"),
            tooltip=[alt.Tooltip("Period:N"), alt.Tooltip("Metric:N"), alt.Tooltip("Normalized:Q")],
        )
        .properties(width="container", height=420)
    )
    st.altair_chart(chart_trend, use_container_width=True)

    st.divider()
    st.subheader("Geospatial Demand Overview")

    try:
        demand_df = run_query("""
            SELECT REGION, SUM(DEMAND_UNITS) AS TOTAL_DEMAND
            FROM MARKET_TRENDS
            WHERE WEEK_DATE = (SELECT MAX(WEEK_DATE) FROM MARKET_TRENDS)
            GROUP BY REGION
            ORDER BY TOTAL_DEMAND DESC
        """)
        if demand_df.empty:
            st.info("No market-trends data for the latest week.")
        else:
            chart_demand = (
                alt.Chart(demand_df)
                .mark_bar(color=ACCENT)
                .encode(
                    x=alt.X("REGION:N", title="Region", sort="-y"),
                    y=alt.Y("TOTAL_DEMAND:Q", title="Demand Units"),
                    tooltip=[alt.Tooltip("REGION:N", title="Region"), alt.Tooltip("TOTAL_DEMAND:Q", title="Demand Units")],
                )
                .properties(width="container", height=380)
            )
            st.altair_chart(chart_demand, use_container_width=True)
    except Exception as e:
        st.warning(f"Could not load demand data: {e}")
