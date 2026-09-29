import streamlit as st
import json
from utils.connection import run_query, get_connection

STARTER_QUESTIONS = {
    "Executive": [
        "Give me an executive summary of all supply chain KPIs",
        "Which KPIs are below target this month?",
        "Compare this month vs last month performance",
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


AGENT_FQN = "__SF_DATABASE__.__SF_SCHEMA__.SCM_ROUTER"


def _extract_text_from_content(content) -> str:
    """Extract text from a Cortex Agent response content array."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        text_parts = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                text_parts.append(item.get("text", ""))
        return "\n".join(p for p in text_parts if p)
    return str(content)


def _call_agent(question: str) -> str:
    """Call the SCM_ROUTER Cortex Agent."""
    errors = []

    body = json.dumps({
        "messages": [
            {"role": "user", "content": [{"type": "text", "text": question}]}
        ],
    })
    body_escaped = body.replace("'", "''")

    # Method 1: DATA_AGENT_RUN SQL function (works in all SiS environments)
    try:
        result = run_query(f"""
            SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
                '{AGENT_FQN}',
                '{body_escaped}'
            ) AS RESPONSE
        """)
        raw = result.iloc[0]["RESPONSE"]
        response = json.loads(raw) if isinstance(raw, str) else raw
        return _extract_text_from_content(response.get("content", []))
    except Exception as e:
        errors.append(f"DATA_AGENT_RUN: {e}")

    # Method 2: _snowflake REST (warehouse-based SiS)
    endpoint = "/api/v2/databases/__SF_DATABASE__/schemas/__SF_SCHEMA__/agents/SCM_ROUTER:run"
    payload = json.dumps({
        "messages": [
            {"role": "user", "content": [{"type": "text", "text": question}]}
        ],
        "stream": False,
    })

    try:
        import _snowflake

        resp = _snowflake.send_snow_api_request(
            "POST", endpoint, {}, {}, payload, {}, 120000,
        )
        status = resp.get("status", 0)
        if status in (200, 201):
            response = json.loads(resp.get("content", "{}"))
            return _extract_text_from_content(response.get("content", []))
        errors.append(f"_snowflake status {status}: {resp.get('content', '')[:300]}")
    except ImportError:
        errors.append("_snowflake not available (SPCS runtime)")
    except Exception as e:
        errors.append(f"_snowflake error: {e}")

    # Method 3: REST via Snowpark session connection (SPCS-based SiS)
    try:
        import urllib.request

        conn = get_connection()
        session = conn.session()
        sf_conn = session._conn._conn
        host = sf_conn.host
        token = sf_conn.rest.token

        req = urllib.request.Request(
            f"https://{host}{endpoint}",
            data=payload.encode(),
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": f'Snowflake Token="{token}"',
            },
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=120) as resp:
            response = json.loads(resp.read().decode())
            return _extract_text_from_content(response.get("content", []))
    except Exception as e:
        errors.append(f"REST via session: {e}")

    return (
        "Could not reach the SCM_ROUTER agent.\n\nDebug info:\n"
        + "\n".join(f"- {e}" for e in errors)
    )


def render(persona: str):
    """Render the Ask Supply Chain chat interface for the given persona."""
    st.markdown("---")
    st.subheader("Ask the Supply Chain")

    questions = STARTER_QUESTIONS.get(persona, STARTER_QUESTIONS["Executive"])
    cols = st.columns(len(questions))
    for i, q in enumerate(questions):
        if cols[i].button(q, key=f"starter_{persona}_{i}", use_container_width=True):
            st.session_state["prefill_question"] = q

    msg_key = f"messages_{persona}"
    if msg_key not in st.session_state:
        st.session_state[msg_key] = []

    for msg in st.session_state[msg_key]:
        role_label = "**You:**" if msg["role"] == "user" else "**Agent:**"
        st.markdown(f"{role_label} {msg['content']}")

    prefill = st.session_state.pop("prefill_question", None)
    col_input, col_btn = st.columns([5, 1])
    with col_input:
        user_input = st.text_input("Ask a supply chain question...", value=prefill or "", key=f"ask_input_{persona}", label_visibility="collapsed")
    with col_btn:
        ask_clicked = st.button("Ask", key=f"ask_btn_{persona}", use_container_width=True)

    if (ask_clicked or prefill) and user_input:
        st.session_state[msg_key].append({"role": "user", "content": user_input})
        st.markdown(f"**You:** {user_input}")

        with st.spinner("Querying the supply chain agent..."):
            response = _call_agent(user_input)

        st.markdown(f"**Agent:** {response}")
        st.session_state[msg_key].append({"role": "assistant", "content": response})

        with st.expander("Why should I trust this?"):
            try:
                rules = run_query("""
                    SELECT RULE_ID, METRIC_NAME, DOMAIN, DEFINITION, FORMULA, UNIT, TARGET, SEMANTIC_VIEW
                    FROM __SF_DATABASE__.__SF_SCHEMA__.BUSINESS_RULES
                    ORDER BY RULE_ID
                """)
                if not rules.empty:
                    st.markdown("**Governing Business Rules**")
                    st.dataframe(rules, use_container_width=True)
                else:
                    st.info("No business rules found.")
            except Exception:
                st.info("Business rules table not available.")
