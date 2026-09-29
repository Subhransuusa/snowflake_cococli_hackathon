import streamlit as st

st.set_page_config(
    page_title="Supply Chain Command Center",
    page_icon="",
    layout="wide",
    initial_sidebar_state="collapsed",
)

# ── Professional CSS ─────────────────────────────────────────────────────────
PERSONA_COLORS = {
    "Executive":   {"accent": "#0D47A1", "bg": "#E3F2FD", "gradient": "linear-gradient(135deg, #0D47A1 0%, #1565C0 50%, #1E88E5 100%)"},
    "Procurement": {"accent": "#1B5E20", "bg": "#E8F5E9", "gradient": "linear-gradient(135deg, #1B5E20 0%, #2E7D32 50%, #43A047 100%)"},
    "Logistics":   {"accent": "#E65100", "bg": "#FFF3E0", "gradient": "linear-gradient(135deg, #E65100 0%, #EF6C00 50%, #F57C00 100%)"},
    "Planning":    {"accent": "#4A148C", "bg": "#F3E5F5", "gradient": "linear-gradient(135deg, #4A148C 0%, #6A1B9A 50%, #7B1FA2 100%)"},
    "Sales":       {"accent": "#B71C1C", "bg": "#FFEBEE", "gradient": "linear-gradient(135deg, #B71C1C 0%, #C62828 50%, #D32F2F 100%)"},
    "Operations":  {"accent": "#006064", "bg": "#E0F7FA", "gradient": "linear-gradient(135deg, #006064 0%, #00838F 50%, #0097A7 100%)"},
}

PERSONA_ICONS = {
    "Executive": "C-Suite",
    "Procurement": "Sourcing",
    "Logistics": "Transport",
    "Planning": "Demand",
    "Sales": "Revenue",
    "Operations": "Cross-Domain",
}

PERSONA_SUBTITLES = {
    "Executive": "Cross-domain KPIs, trends, and risk signals",
    "Procurement": "Supplier performance, cost analysis, and SLA tracking",
    "Logistics": "Carrier OTD, lane costs, and transport analytics",
    "Planning": "Inventory health, stockout risk, and demand forecasting",
    "Sales": "Fill rates, fulfillment trends, and customer satisfaction",
    "Operations": "Inventory + fulfillment + logistics convergence view",
}


def inject_css(persona: str):
    colors = PERSONA_COLORS[persona]
    st.markdown(f"""
    <style>
        /* Hide default sidebar nav */
        [data-testid="stSidebarNav"] {{ display: none; }}

        /* Hide sidebar expand button */
        button[kind="header"] {{ display: none; }}

        /* Header banner */
        .persona-header {{
            background: {colors["gradient"]};
            padding: 1.5rem 2rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            color: white;
        }}
        .persona-header h1 {{
            margin: 0;
            font-size: 1.8rem;
            font-weight: 700;
            color: white;
        }}
        .persona-header p {{
            margin: 0.25rem 0 0 0;
            font-size: 1rem;
            opacity: 0.9;
            color: white;
        }}

        /* Metric cards styling */
        [data-testid="stMetric"] {{
            background: {colors["bg"]};
            border-left: 4px solid {colors["accent"]};
            padding: 0.75rem 1rem;
            border-radius: 8px;
        }}
        [data-testid="stMetricLabel"] {{
            font-weight: 600;
        }}

        /* Tabs styling */
        .stTabs [data-baseweb="tab-list"] {{
            gap: 8px;
        }}
        .stTabs [data-baseweb="tab"] {{
            border-radius: 8px 8px 0 0;
            padding: 0.5rem 1.5rem;
            font-weight: 600;
        }}

        /* Dividers */
        hr {{
            border-color: {colors["bg"]};
        }}

        /* Buttons */
        .stButton > button {{
            border: 1px solid {colors["accent"]};
            color: {colors["accent"]};
            border-radius: 8px;
            font-size: 0.8rem;
            padding: 0.3rem 0.6rem;
        }}
        .stButton > button:hover {{
            background: {colors["bg"]};
            border-color: {colors["accent"]};
        }}

        /* Selectbox on main page */
        .persona-selector {{
            max-width: 220px;
        }}

        /* Footer */
        .footer {{
            text-align: center;
            padding: 1rem;
            color: #9E9E9E;
            font-size: 0.8rem;
            margin-top: 2rem;
        }}

        /* Snowflake masthead */
        .sf-masthead {{
            background: linear-gradient(135deg, #29B5E8 0%, #11567F 100%);
            padding: 1.2rem 2rem;
            border-radius: 12px;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 16px;
        }}
        .sf-masthead .sf-icon {{
            width: 48px;
            height: 48px;
            flex-shrink: 0;
        }}
        .sf-masthead .sf-title {{
            margin: 0;
            font-size: 1.5rem;
            font-weight: 700;
            color: #FFFFFF;
            letter-spacing: 0.3px;
        }}
        .sf-masthead .sf-subtitle {{
            margin: 0.15rem 0 0 0;
            font-size: 0.85rem;
            color: rgba(255,255,255,0.85);
            font-weight: 400;
        }}
    </style>
    """, unsafe_allow_html=True)


# ── Snowflake Masthead ──────────────────────────────────────────────────────
SNOWFLAKE_SVG = '''<svg class="sf-icon" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="48" fill="rgba(255,255,255,0.15)" stroke="rgba(255,255,255,0.3)" stroke-width="2"/>
  <g transform="translate(50,50)" stroke="white" stroke-width="3.5" stroke-linecap="round" fill="none">
    <line y1="-28" y2="28"/>
    <line y1="-28" y2="28" transform="rotate(60)"/>
    <line y1="-28" y2="28" transform="rotate(120)"/>
    <line x1="-8" y1="-24" x2="8" y2="-24"/><line x1="-8" y1="24" x2="8" y2="24"/>
    <line x1="-8" y1="-24" x2="8" y2="-24" transform="rotate(60)"/><line x1="-8" y1="24" x2="8" y2="24" transform="rotate(60)"/>
    <line x1="-8" y1="-24" x2="8" y2="-24" transform="rotate(120)"/><line x1="-8" y1="24" x2="8" y2="24" transform="rotate(120)"/>
    <circle r="5" fill="white"/>
  </g>
</svg>'''

st.markdown(f"""
<div class="sf-masthead">
    {SNOWFLAKE_SVG}
    <div>
        <p class="sf-title">MFG: Supply Chain Ontology &amp; Governed Conversational Analytics</p>
        <p class="sf-subtitle">Powered by Snowflake Cortex Agents &middot; Semantic Views &middot; CoCo CLI</p>
    </div>
</div>
""", unsafe_allow_html=True)


# ── Persona selector at top-left ─────────────────────────────────────────────
PERSONAS = ["Executive", "Procurement", "Logistics", "Planning", "Sales", "Operations"]

col_selector, col_spacer = st.columns([1, 4])
with col_selector:
    persona = st.selectbox(
        "Persona",
        PERSONAS,
        index=PERSONAS.index(st.session_state.get("persona", "Executive")),
        label_visibility="collapsed",
        key="persona_select",
    )
st.session_state["persona"] = persona

inject_css(persona)

# ── Header banner ────────────────────────────────────────────────────────────
subtitle = PERSONA_SUBTITLES[persona]
tag = PERSONA_ICONS[persona]
st.markdown(f"""
<div class="persona-header">
    <h1>Supply Chain Command Center &middot; {persona}</h1>
    <p>{tag} &mdash; {subtitle}</p>
</div>
""", unsafe_allow_html=True)

# ── Tabs: Dashboard | Ask Supply Chain | Governance ──────────────────────────
tab_dashboard, tab_ask, tab_governance = st.tabs(["Dashboard", "Ask Supply Chain", "Governance & Trust"])

from views import (
    exec_view, procurement_view, logistics_view,
    planning_view, sales_view, operations_view,
    ask_view, governance_view,
)

VIEW_MAP = {
    "Executive": exec_view,
    "Procurement": procurement_view,
    "Logistics": logistics_view,
    "Planning": planning_view,
    "Sales": sales_view,
    "Operations": operations_view,
}

with tab_dashboard:
    VIEW_MAP[persona].render()

with tab_ask:
    ask_view.render(persona)

with tab_governance:
    governance_view.render()

# ── Footer ───────────────────────────────────────────────────────────────────
st.markdown("""
<div class="footer">
    Powered by Snowflake Cortex Agents &middot; 6 Semantic Views &middot; 5 Domain Skills &middot; 5 Agents
</div>
""", unsafe_allow_html=True)
