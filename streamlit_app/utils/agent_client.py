import json

ROUTER_AGENT = "__SF_DATABASE__.__SF_SCHEMA__.SCM_ROUTER"


def _extract_text_from_content(content):
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


def run_agent(question, agent_fqn=None):
    """Call a Cortex Agent via DATA_AGENT_RUN SQL function."""
    from utils.connection import run_query

    agent = agent_fqn or ROUTER_AGENT
    body = json.dumps({
        "messages": [
            {"role": "user", "content": [{"type": "text", "text": question}]}
        ],
    })
    body_escaped = body.replace("'", "''")

    result = run_query(f"""
        SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
            '{agent}',
            '{body_escaped}'
        ) AS RESPONSE
    """)
    raw = result.iloc[0]["RESPONSE"]
    parsed = json.loads(raw) if isinstance(raw, str) else raw

    response_text = _extract_text_from_content(parsed.get("content", []))
    trace = _parse_trace(parsed)
    return response_text, trace


def _parse_trace(parsed_response):
    """Extract tool usage trace from the agent response."""
    trace = {"tools_used": [], "elapsed": None}
    content = parsed_response.get("content", [])
    if isinstance(content, list):
        for item in content:
            if isinstance(item, dict) and item.get("type") == "tool_use":
                tool_info = item.get("tool_use", {})
                trace["tools_used"].append(tool_info.get("name", "unknown"))
        trace["raw"] = parsed_response
    return trace
