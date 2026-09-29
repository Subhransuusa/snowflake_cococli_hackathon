import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd

@st.cache_resource
def get_session():
    return get_active_session()

def run_query(sql, params=None):
    session = get_session()
    if params:
        for k, v in params.items():
            sql = sql.replace(f"%({k})s", str(v))
    return session.sql(sql).to_pandas()

def get_connection():
    return get_session()
