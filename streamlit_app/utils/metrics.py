from utils.connection import run_query
import streamlit as st

PERSONAS = ["Executive", "Procurement", "Logistics", "Planning", "Sales", "Operations"]

PERSONA_PAGES = {
    "Executive": "Executive",
    "Procurement": "Procurement",
    "Logistics": "Logistics",
    "Planning": "Planning",
    "Sales": "Sales",
    "Operations": "Operations",
}

STARTER_QUESTIONS = {
    "Executive": [
        "Give me an executive summary of all supply chain KPIs",
        "Which KPIs are below target this month?",
        "Compare this month's performance vs last month",
    ],
    "Procurement": [
        "What is the on-time delivery rate by supplier?",
        "Which supplier has the highest landed cost?",
        "Average lead time vs contracted lead time by supplier?",
    ],
    "Logistics": [
        "Which carrier has the best delivery OTD?",
        "Compare freight costs by transport mode",
        "Which routes have the highest risk?",
    ],
    "Planning": [
        "What is the average days of inventory by plant?",
        "Which critical parts are below safety stock?",
        "What categories show growing demand in North America?",
    ],
    "Sales": [
        "What is the fill rate by customer segment?",
        "Which parts have the lowest fill rate?",
        "Fill rate trend by month?",
    ],
    "Operations": [
        "Parts with growing demand but below safety stock?",
        "Which plants have both low DOI and low fill rate?",
        "Cross-domain risk: low inventory + delayed shipments?",
    ],
}

def get_executive_summary():
    return run_query("SELECT * FROM __SF_DATABASE__.__SF_SCHEMA__.V_SCM_EXECUTIVE_SUMMARY ORDER BY PERIOD")

def get_supplier_otd(months_back=12):
    return run_query("""
        SELECT SUPPLIER_NAME, ORDER_MONTH, OTD_PCT, TOTAL_POS, ON_TIME_POS
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_ON_TIME_DELIVERY
        WHERE ORDER_MONTH >= DATEADD('month', -%(months)s, CURRENT_DATE())
        ORDER BY ORDER_MONTH, SUPPLIER_NAME
    """, params={"months": months_back})

def get_fill_rate(months_back=12):
    return run_query("""
        SELECT CUSTOMER_NAME, SEGMENT, PLANT_NAME, ORDER_MONTH, 
               TOTAL_ORDERED, TOTAL_FULFILLED, FILL_RATE_PCT
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_FILL_RATE
        WHERE ORDER_MONTH >= DATEADD('month', -%(months)s, CURRENT_DATE())
        ORDER BY ORDER_MONTH
    """, params={"months": months_back})

def get_days_of_inventory():
    return run_query("""
        SELECT PLANT_NAME, PART_NAME, CATEGORY, SNAPSHOT_DATE,
               ON_HAND_QTY, SAFETY_STOCK_QTY, AVG_DAILY_USAGE,
               DAYS_OF_INVENTORY, INVENTORY_STATUS
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_DAYS_OF_INVENTORY
        WHERE SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM __SF_DATABASE__.__SF_SCHEMA__.V_DAYS_OF_INVENTORY)
        ORDER BY DAYS_OF_INVENTORY ASC
    """)

def get_landed_cost(months_back=12):
    return run_query("""
        SELECT SUPPLIER_NAME, SUPPLIER_COUNTRY, PLANT_NAME, PART_NAME,
               ORDER_MONTH, ORDERED_QTY, MATERIAL_COST, FREIGHT_COST,
               DUTY_COST, HANDLING_COST, TOTAL_LANDED_COST, LANDED_COST_PER_UNIT
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_LANDED_COST
        WHERE ORDER_MONTH >= DATEADD('month', -%(months)s, CURRENT_DATE())
        ORDER BY ORDER_MONTH
    """, params={"months": months_back})

def get_shipment_otd(months_back=12):
    return run_query("""
        SELECT CUSTOMER_NAME, SEGMENT, PLANT_NAME, CARRIER, TRANSPORT_MODE,
               SHIP_MONTH, TOTAL_SHIPMENTS, ON_TIME_DELIVERIES, DELIVERY_OTD_PCT
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_SHIPMENT_OTD
        WHERE SHIP_MONTH >= DATEADD('month', -%(months)s, CURRENT_DATE())
        ORDER BY SHIP_MONTH
    """, params={"months": months_back})

def get_demand_trends():
    return run_query("""
        SELECT REGION, CATEGORY, WEEK_DATE, DEMAND_UNITS, FORECAST_UNITS,
               TREND_SIGNAL, TREND_SLOPE, YOY_GROWTH_PCT
        FROM __SF_DATABASE__.__SF_SCHEMA__.MARKET_TRENDS
        ORDER BY WEEK_DATE DESC
    """)

def get_demand_forecast():
    return run_query("""
        SELECT df.PART_ID, p.PART_NAME, p.CATEGORY, df.REGION,
               df.FORECAST_DATE, df.FORECAST_QTY, df.LOWER_BOUND, 
               df.UPPER_BOUND, df.CONFIDENCE
        FROM __SF_DATABASE__.__SF_SCHEMA__.DEMAND_FORECAST df
        JOIN __SF_DATABASE__.__SF_SCHEMA__.PARTS p ON df.PART_ID = p.PART_ID
        ORDER BY df.FORECAST_DATE
    """)

def get_business_rules():
    return run_query("SELECT * FROM __SF_DATABASE__.__SF_SCHEMA__.BUSINESS_RULES ORDER BY RULE_ID")

def get_consistency_results():
    return run_query("SELECT * FROM __SF_DATABASE__.__SF_SCHEMA__.NL_CONSISTENCY_RESULTS ORDER BY TEST_ID")

def get_stockout_risk():
    return run_query("""
        SELECT PLANT_NAME, PART_NAME, CATEGORY, ON_HAND_QTY, 
               SAFETY_STOCK_QTY, DAYS_OF_INVENTORY, INVENTORY_STATUS
        FROM __SF_DATABASE__.__SF_SCHEMA__.V_DAYS_OF_INVENTORY
        WHERE SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM __SF_DATABASE__.__SF_SCHEMA__.V_DAYS_OF_INVENTORY)
          AND INVENTORY_STATUS = 'Below Safety Stock'
        ORDER BY DAYS_OF_INVENTORY ASC
    """)

def get_shipping_routes():
    return run_query("""
        SELECT ROUTE_ID, SUPPLIER_ID, PLANT_ID, TRANSPORT_MODE, 
               DISTANCE_KM, EST_TRANSIT_DAYS, EST_COST_USD, RISK_LEVEL, TRADE_LANE
        FROM __SF_DATABASE__.__SF_SCHEMA__.SHIPPING_ROUTES
        ORDER BY DISTANCE_KM
    """)
