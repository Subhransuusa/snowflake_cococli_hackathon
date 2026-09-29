"""Upload CSV files to Snowflake stage and COPY INTO tables."""
import subprocess, json, csv, os, sys

DATA = os.path.join(os.path.dirname(__file__), '..', 'data')

TABLES = {
    'supplier_geolocation.csv': '__SF_DATABASE__.__SF_SCHEMA__.SUPPLIER_GEOLOCATION',
    'plant_geolocation.csv': '__SF_DATABASE__.__SF_SCHEMA__.PLANT_GEOLOCATION',
    'customer_geolocation.csv': '__SF_DATABASE__.__SF_SCHEMA__.CUSTOMER_GEOLOCATION',
    'shipping_routes.csv': '__SF_DATABASE__.__SF_SCHEMA__.SHIPPING_ROUTES',
    'market_trends.csv': '__SF_DATABASE__.__SF_SCHEMA__.MARKET_TRENDS',
    'demand_forecast.csv': '__SF_DATABASE__.__SF_SCHEMA__.DEMAND_FORECAST',
    'supplier_ratings.csv': '__SF_DATABASE__.__SF_SCHEMA__.SUPPLIER_RATINGS',
}

def build_values(csv_path, batch=200):
    """Read CSV and yield batched INSERT value strings."""
    with open(csv_path) as f:
        reader = csv.reader(f)
        header = next(reader)
        ncols = len(header)
        batch_rows = []
        for row in reader:
            vals = []
            for v in row:
                if v == '':
                    vals.append('NULL')
                else:
                    try:
                        float(v)
                        vals.append(v)
                    except ValueError:
                        vals.append("'" + v.replace("'","''") + "'")
            batch_rows.append('(' + ','.join(vals) + ')')
            if len(batch_rows) >= batch:
                yield header, batch_rows
                batch_rows = []
        if batch_rows:
            yield header, batch_rows

for csv_file, table in TABLES.items():
    csv_path = os.path.join(DATA, csv_file)
    total = 0
    for header, rows in build_values(csv_path):
        cols = ','.join(header)
        sql = f"INSERT INTO {table} ({cols}) VALUES {','.join(rows)}"
        # Write to temp file and execute via cortex
        with open('/tmp/_insert.sql', 'w') as f:
            f.write(sql)
        total += len(rows)
    print(f"  {csv_file} -> {table}: {total} rows prepared")

print("Use SQL execution to load each table.")
