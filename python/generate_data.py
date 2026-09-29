"""
Phase 1: Generate synthetic geospatial, market-trend, and supplier-rating data.
Outputs CSV files into ../data/ and supplier rating text docs into ../data/supplier_ratings/
"""
import csv, os, random, math, datetime

random.seed(42)
DATA = os.path.join(os.path.dirname(__file__), '..', 'data')
RATING_DIR = os.path.join(DATA, 'supplier_ratings')
os.makedirs(RATING_DIR, exist_ok=True)

# ── reference data (must match existing tables) ──────────────────────────
SUPPLIERS = [
    ("SUP001","Apex Materials Corp","United States","North America",1,96.5,39.8284,-98.5795),
    ("SUP002","Yangtze Components Ltd","China","Asia Pacific",2,88.2,31.2304,121.4737),
    ("SUP003","Rhine Precision GmbH","Germany","Europe",1,97.8,48.7758,9.1829),
    ("SUP004","Tata Industrial Supply","India","Asia Pacific",2,85.4,19.0760,72.8777),
    ("SUP005","Maple Fasteners Inc","Canada","North America",2,91.3,43.6532,-79.3832),
    ("SUP006","Sakura Electronics Co","Japan","Asia Pacific",1,98.1,35.6762,139.6503),
    ("SUP007","Sao Paulo Metals SA","Brazil","South America",3,78.6,-23.5505,-46.6333),
    ("SUP008","Nordic Alloys AB","Sweden","Europe",2,92.7,59.3293,18.0686),
    ("SUP009","Delta Plastics LLC","United States","North America",3,82.4,33.7490,-84.3880),
    ("SUP010","Seoul Semiconductor Inc","South Korea","Asia Pacific",1,95.9,37.5665,126.9780),
    ("SUP011","Anatolian Castings AS","Turkey","Europe",3,79.5,41.0082,28.9784),
    ("SUP012","Melbourne Rubber Pty","Australia","Asia Pacific",3,81.3,-37.8136,144.9631),
    ("SUP013","Guadalajara Motors SA","Mexico","North America",2,89.7,20.6597,-103.3496),
    ("SUP014","Thames Bearings Ltd","United Kingdom","Europe",1,94.2,51.5074,-0.1278),
    ("SUP015","Shenzhen PCB Tech Co","China","Asia Pacific",2,87.6,22.5431,114.0579),
]

PLANTS = [
    ("PLT001","Detroit Assembly Hub","United States","North America",42.3314,-83.0458),
    ("PLT002","Stuttgart Manufacturing","Germany","Europe",48.7758,9.1829),
    ("PLT003","Shanghai Mega Plant","China","Asia Pacific",31.2304,121.4737),
    ("PLT004","Monterrey Operations","Mexico","North America",25.6866,-100.3161),
    ("PLT005","Chennai Production Center","India","Asia Pacific",13.0827,80.2707),
    ("PLT006","Toronto Distribution","Canada","North America",43.6532,-79.3832),
    ("PLT007","Prague Assembly Works","Czech Republic","Europe",50.0755,14.4378),
    ("PLT008","Nagoya Precision Plant","Japan","Asia Pacific",35.1815,136.9066),
]

CUSTOMERS = [
    ("CUS001",42.3314,-83.0458),("CUS002",48.1351,11.5820),("CUS003",34.6937,135.5023),
    ("CUS004",51.5074,-0.1278),("CUS005",39.7392,-104.9903),("CUS006",40.4168,-3.7038),
    ("CUS007",42.3601,-71.0589),("CUS008",39.9042,116.4074),("CUS009",49.2827,-123.1207),
    ("CUS010",59.9139,10.7522),("CUS011",-31.9505,115.8605),("CUS012",19.0760,72.8777),
    ("CUS013",38.8816,-77.0910),("CUS014",-33.4489,-70.6693),("CUS015",47.5596,7.5886),
    ("CUS016",41.0082,28.9784),("CUS017",41.2565,-95.9345),("CUS018",35.6762,139.6503),
    ("CUS019",55.6761,12.5683),("CUS020",-3.1190,-60.0217),
]

# ── 1. SUPPLIER_GEOLOCATION ─────────────────────────────────────────────
rows = []
for sid,name,country,region,tier,rel,lat,lng in SUPPLIERS:
    rows.append([sid,name,country,region,lat,lng,
                 round(lat+random.uniform(-0.05,0.05),6),
                 round(lng+random.uniform(-0.05,0.05),6),
                 f"Industrial Zone {random.randint(1,20)}",
                 random.choice(["Port","Airport","Rail Hub","Highway Interchange"]),
                 round(random.uniform(5,120),1)])
with open(os.path.join(DATA,'supplier_geolocation.csv'),'w',newline='') as f:
    w=csv.writer(f); w.writerow(['SUPPLIER_ID','SUPPLIER_NAME','COUNTRY','REGION',
        'LATITUDE','LONGITUDE','WAREHOUSE_LAT','WAREHOUSE_LNG',
        'INDUSTRIAL_ZONE','NEAREST_HUB_TYPE','DISTANCE_TO_HUB_KM'])
    w.writerows(rows)
print(f"supplier_geolocation.csv: {len(rows)} rows")

# ── 2. PLANT_GEOLOCATION ────────────────────────────────────────────────
rows = []
for pid,name,country,region,lat,lng in PLANTS:
    rows.append([pid,name,country,region,lat,lng,
                 random.choice(["Port","Airport","Rail Hub","Highway Interchange"]),
                 round(random.uniform(2,80),1)])
with open(os.path.join(DATA,'plant_geolocation.csv'),'w',newline='') as f:
    w=csv.writer(f); w.writerow(['PLANT_ID','PLANT_NAME','COUNTRY','REGION',
        'LATITUDE','LONGITUDE','NEAREST_HUB_TYPE','DISTANCE_TO_HUB_KM'])
    w.writerows(rows)
print(f"plant_geolocation.csv: {len(rows)} rows")

# ── 3. CUSTOMER_GEOLOCATION ─────────────────────────────────────────────
rows = []
for cid,lat,lng in CUSTOMERS:
    rows.append([cid,lat,lng,
                 random.choice(["Urban","Suburban","Industrial","Rural"]),
                 round(random.uniform(10,500),1)])
with open(os.path.join(DATA,'customer_geolocation.csv'),'w',newline='') as f:
    w=csv.writer(f); w.writerow(['CUSTOMER_ID','LATITUDE','LONGITUDE','ZONE_TYPE','TRADE_AREA_RADIUS_KM'])
    w.writerows(rows)
print(f"customer_geolocation.csv: {len(rows)} rows")

# ── 4. SHIPPING_ROUTES (supplier→plant optimal routes) ──────────────────
def haversine(lat1,lon1,lat2,lon2):
    R=6371; dlat=math.radians(lat2-lat1); dlon=math.radians(lon2-lon1)
    a=math.sin(dlat/2)**2+math.cos(math.radians(lat1))*math.cos(math.radians(lat2))*math.sin(dlon/2)**2
    return R*2*math.asin(math.sqrt(a))

rows = []; rid=0
for sid,sname,scountry,sregion,stier,srel,slat,slng in SUPPLIERS:
    for pid,pname,pcountry,pregion,plat,plng in PLANTS:
        dist = haversine(slat,slng,plat,plng)
        if dist < 15000:
            rid+=1
            mode = "Ocean" if dist>3000 else ("Air" if dist>1500 else ("Rail" if dist>500 else "Truck"))
            transit = round(dist/800 + random.uniform(0.5,3),1) if mode=="Truck" else round(dist/400+random.uniform(1,5),1) if mode=="Rail" else round(dist/600+random.uniform(2,7),1) if mode=="Ocean" else round(dist/2000+random.uniform(0.5,2),1)
            cost_per_km = {"Truck":2.5,"Rail":1.2,"Ocean":0.3,"Air":5.0}[mode]
            rows.append([f"RTE-{rid:04d}",sid,pid,sname,pname,
                         round(slat,4),round(slng,4),round(plat,4),round(plng,4),
                         round(dist,1),mode,round(transit,1),
                         round(dist*cost_per_km/1000,2),
                         random.choice(["Direct","Via Hub","Multi-stop"]),
                         random.choice(["Low","Medium","High"]),
                         random.choice(["Suez Canal","Panama Canal","Trans-Pacific","Trans-Atlantic","Continental","Domestic","Regional"])])
with open(os.path.join(DATA,'shipping_routes.csv'),'w',newline='') as f:
    w=csv.writer(f); w.writerow(['ROUTE_ID','SUPPLIER_ID','PLANT_ID','SUPPLIER_NAME','PLANT_NAME',
        'ORIGIN_LAT','ORIGIN_LNG','DEST_LAT','DEST_LNG','DISTANCE_KM',
        'TRANSPORT_MODE','EST_TRANSIT_DAYS','EST_COST_USD','ROUTE_TYPE',
        'RISK_LEVEL','TRADE_LANE'])
    w.writerows(rows)
print(f"shipping_routes.csv: {len(rows)} rows")

# ── 5. MARKET_TRENDS (weekly demand signals by region/category) ─────────
categories = ["Structural","Electrical","Hydraulics","Consumables","Electronics",
              "Mechanical","Pneumatics"]
regions = ["North America","Europe","Asia Pacific","South America"]
base = datetime.date(2025,9,1)
rows = []
for region in regions:
    for cat in categories:
        base_demand = random.uniform(500,5000)
        trend_slope = random.uniform(-5,15)
        seasonality = random.uniform(0.05,0.25)
        for week in range(52):
            dt = base + datetime.timedelta(weeks=week)
            seasonal = math.sin(2*math.pi*week/52)*seasonality*base_demand
            trend_val = trend_slope*week
            noise = random.gauss(0, base_demand*0.08)
            demand = max(50, base_demand + seasonal + trend_val + noise)
            yoy_growth = round(random.uniform(-10,30),2)
            confidence = round(random.uniform(0.6,0.98),2)
            rows.append([dt.isoformat(), region, cat, round(demand,0),
                         round(demand*random.uniform(0.85,1.15),0),
                         round(trend_slope,2), yoy_growth, confidence,
                         "Growing" if trend_slope>3 else ("Declining" if trend_slope<-2 else "Stable"),
                         round(base_demand+trend_val,0)])
with open(os.path.join(DATA,'market_trends.csv'),'w',newline='') as f:
    w=csv.writer(f); w.writerow(['WEEK_DATE','REGION','CATEGORY','DEMAND_UNITS',
        'FORECAST_UNITS','TREND_SLOPE','YOY_GROWTH_PCT','CONFIDENCE_SCORE',
        'TREND_SIGNAL','BASELINE_DEMAND'])
    w.writerows(rows)
print(f"market_trends.csv: {len(rows)} rows")

# ── 6. DEMAND_FORECAST (part-level 12-week forward forecast) ────────────
PARTS = [f"PRT{i:03d}" for i in range(1,21)]
rows = []
for region in regions:
    for part in PARTS:
        base_fc = random.uniform(100,2000)
        for week in range(12):
            dt = datetime.date.today() + datetime.timedelta(weeks=week)
            fc = max(10, base_fc + random.gauss(0, base_fc*0.1) + week*random.uniform(-2,5))
            rows.append([dt.isoformat(), region, part, round(fc,0),
                         round(fc*random.uniform(0.8,1.0),0),
                         round(fc*random.uniform(1.0,1.2),0),
                         round(random.uniform(0.65,0.95),2),
                         "ML_Ensemble_v3"])
with open(os.path.join(DATA,'demand_forecast.csv'),'w',newline='') as f:
    w=csv.writer(f); w.writerow(['FORECAST_DATE','REGION','PART_ID','FORECAST_QTY',
        'LOWER_BOUND','UPPER_BOUND','CONFIDENCE','MODEL_VERSION'])
    w.writerows(rows)
print(f"demand_forecast.csv: {len(rows)} rows")

# ── 7. SUPPLIER_RATINGS (structured scores) ─────────────────────────────
rating_rows = []
for sid,name,country,region,tier,rel,lat,lng in SUPPLIERS:
    quality = round(random.uniform(60,99),1)
    delivery = round(rel + random.uniform(-5,5),1)
    cost_comp = round(random.uniform(55,95),1)
    responsiveness = round(random.uniform(60,98),1)
    sustainability = round(random.uniform(40,95),1)
    innovation = round(random.uniform(50,95),1)
    overall = round((quality*0.25+delivery*0.25+cost_comp*0.2+responsiveness*0.15+sustainability*0.1+innovation*0.05),1)
    risk = "Low" if overall>85 else ("Medium" if overall>70 else "High")
    cert = random.choice(["ISO 9001, ISO 14001","ISO 9001","ISO 9001, IATF 16949","ISO 9001, AS9100","None"])
    rating_rows.append([sid,name,country,region,tier,quality,delivery,cost_comp,
                        responsiveness,sustainability,innovation,overall,risk,cert,
                        datetime.date.today().isoformat()])
with open(os.path.join(DATA,'supplier_ratings.csv'),'w',newline='') as f:
    w=csv.writer(f); w.writerow(['SUPPLIER_ID','SUPPLIER_NAME','COUNTRY','REGION','TIER',
        'QUALITY_SCORE','DELIVERY_SCORE','COST_COMPETITIVENESS','RESPONSIVENESS',
        'SUSTAINABILITY_SCORE','INNOVATION_SCORE','OVERALL_RATING','RISK_LEVEL',
        'CERTIFICATIONS','RATING_DATE'])
    w.writerows(rating_rows)
print(f"supplier_ratings.csv: {len(rating_rows)} rows")

# ── 8. SUPPLIER_RATING DOCUMENTS (text files for Cortex Search) ─────────
for row in rating_rows:
    sid,name,country,region,tier = row[0],row[1],row[2],row[3],row[4]
    quality,delivery,cost,resp,sust,innov,overall,risk,cert = row[5:14]

    strengths = []
    weaknesses = []
    if quality > 85: strengths.append("Consistently high product quality with minimal defect rates")
    else: weaknesses.append(f"Quality score of {quality} indicates room for improvement in defect management")
    if delivery > 90: strengths.append("Excellent delivery reliability and on-time performance")
    else: weaknesses.append(f"Delivery score of {delivery} suggests late shipments are a recurring concern")
    if cost > 80: strengths.append("Competitive pricing structure with transparent cost breakdown")
    else: weaknesses.append(f"Cost competitiveness at {cost} is below benchmark; consider renegotiation")
    if resp > 85: strengths.append("Highly responsive to urgent orders and change requests")
    if sust > 75: strengths.append("Strong sustainability practices with environmental certifications")
    else: weaknesses.append(f"Sustainability score of {sust} falls short of corporate ESG targets")
    if innov > 80: strengths.append("Proactive in proposing design improvements and new materials")

    recommendation = "PREFERRED" if overall>85 else ("APPROVED" if overall>70 else "PROBATIONARY")
    capacity_note = random.choice([
        "Supplier has demonstrated capacity to handle 20% surge orders within 2-week notice.",
        "Capacity constraints observed during Q4 peak season; requires advance planning.",
        "Dual-facility capability provides redundancy for critical part supply.",
        "Single-site operation presents concentration risk; suggest qualifying backup.",
    ])
    audit_finding = random.choice([
        "Last audit (2026-Q1): No major findings. Minor observation on traceability documentation.",
        "Last audit (2026-Q2): One corrective action issued for incoming inspection procedure gaps.",
        "Last audit (2025-Q4): Clean audit. All corrective actions from prior audits verified closed.",
        "Last audit (2026-Q1): Two observations noted regarding environmental waste handling procedures.",
    ])

    doc = f"""SUPPLIER PERFORMANCE REVIEW
{'='*60}
Supplier: {name}
Supplier ID: {sid}
Country: {country} | Region: {region}
Tier: {tier} | Certifications: {cert}
Review Date: {datetime.date.today().isoformat()}
Overall Rating: {overall}/100 | Classification: {recommendation}
Risk Level: {risk}

SCORECARD
{'-'*60}
Quality Score:           {quality}/100
Delivery Score:          {delivery}/100
Cost Competitiveness:    {cost}/100
Responsiveness:          {resp}/100
Sustainability:          {sust}/100
Innovation:              {innov}/100
Overall Weighted Rating: {overall}/100

STRENGTHS
{'-'*60}
{chr(10).join(f"  - {s}" for s in strengths) if strengths else "  - No standout strengths identified in this review cycle."}

AREAS FOR IMPROVEMENT
{'-'*60}
{chr(10).join(f"  - {w}" for w in weaknesses) if weaknesses else "  - Supplier meets or exceeds all benchmarks."}

CAPACITY & OPERATIONS
{'-'*60}
{capacity_note}

AUDIT HISTORY
{'-'*60}
{audit_finding}

RECOMMENDATION
{'-'*60}
Based on the overall rating of {overall}/100, this supplier is classified as
{recommendation}. {'This supplier should be prioritized for critical and high-value purchase orders.' if recommendation=='PREFERRED' else 'This supplier may be used for standard orders but should not be sole-sourced for critical parts.' if recommendation=='APPROVED' else 'This supplier requires close monitoring and a corrective action plan within 90 days.'}

{'='*60}
End of Review - Confidential
"""
    with open(os.path.join(RATING_DIR, f"{sid}_{name.replace(' ','_')}_review.txt"), 'w') as f:
        f.write(doc)

print(f"supplier_ratings docs: {len(rating_rows)} files written")
print("\nAll synthetic data generated successfully.")
