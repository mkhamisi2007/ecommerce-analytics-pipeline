# E-Commerce Analytics Pipeline

A production-grade, end-to-end data pipeline built on the [Brazilian E-Commerce (Olist) public dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). This project demonstrates real-world Data Engineering skills: ingestion, transformation, orchestration, CI/CD, and business intelligence — all wired together and running on a live Snowflake warehouse.

![dbt](https://img.shields.io/badge/dbt_Core-1.11-orange?logo=dbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-Data_Warehouse-29B5E8?logo=snowflake&logoColor=white)
![Dagster](https://img.shields.io/badge/Dagster-Orchestration-7E57C2?logo=dagster&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Desktop-2496ED?logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                             │
│   Kaggle: Brazilian E-Commerce (Olist) — 5 CSV files           │
└────────────────────────┬────────────────────────────────────────┘
                         │  Python + pandas
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SNOWFLAKE (ECOMMERCE_DB)                    │
│                                                                 │
│  RAW schema              ← raw CSV tables (5 tables)           │
│                                                                 │
│  dbt_dev_staging         ← typed & renamed views (5 models)    │
│  dbt_dev_intermediate    ← joined & enriched views (2 models)  │
│  dbt_dev_marts           ← final analytics tables (2 models)   │
│  snapshots               ← SCD Type 2 orders history           │
│  dbt_dev_seeds           ← product category lookup             │
└──────────┬──────────────────────────────────┬───────────────────┘
           │  dbt Core                        │  Metabase
           ▼                                  ▼
┌─────────────────────┐            ┌──────────────────────────────┐
│  Dagster            │            │  Metabase Dashboard          │
│  (Orchestration)    │            │  localhost:3001              │
│  localhost:3000     │            │  Charts from mart tables     │
│  - Daily 06:00 UTC  │            └──────────────────────────────┘
│  - Weekly snapshots │
└─────────────────────┘
           │  GitHub Actions
           ▼
┌─────────────────────────────────────────────────────────────────┐
│  CI/CD                                                          │
│  PR  → dbt test --select staging                               │
│  Merge to main → dbt seed + run + test + snapshot             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Warehouse | Snowflake | Cloud data warehouse |
| Transformation | dbt Core 1.11 | SQL models, tests, snapshots |
| Orchestration | Dagster | Asset-based pipeline scheduling |
| Ingestion | Python 3.11 + pandas | Load CSVs into Snowflake |
| BI Dashboard | Metabase | Self-hosted charts & dashboards |
| CI/CD | GitHub Actions | Automated testing on every PR |
| Containers | Docker Desktop | Dagster + Metabase via docker-compose |

---

## Dataset

**Brazilian E-Commerce Public Dataset by Olist** — 100,000 real orders from 2016–2018.

| File | Loaded as | Rows |
|------|-----------|------|
| `olist_orders_dataset.csv` | `RAW.ORDERS` | 99,441 |
| `olist_order_items_dataset.csv` | `RAW.ORDER_ITEMS` | 112,650 |
| `olist_customers_dataset.csv` | `RAW.CUSTOMERS` | 99,441 |
| `olist_products_dataset.csv` | `RAW.PRODUCTS` | 32,951 |
| `olist_order_reviews_dataset.csv` | `RAW.REVIEWS` | 99,224 |

---

## Prerequisites

- **Python 3.11** (3.12 works; 3.14 does NOT — snowflake-connector incompatibility)
- **Snowflake account** — [free 30-day trial](https://signup.snowflake.com/)
- **Docker Desktop** — for Dagster + Metabase containers
- **Olist CSV files** — placed in a `kaggle-data/` folder one level above the project root

---

## Project Structure

```
ecommerce-analytics-pipeline/
├── kaggle-data/                     # CSV source files (~120 MB, included in repo)
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_customers_dataset.csv
│   ├── olist_products_dataset.csv
│   └── olist_order_reviews_dataset.csv
├── .github/
│   └── workflows/
│       ├── dbt_test_on_pr.yml       # Run dbt tests on every PR
│       └── dbt_run_on_merge.yml     # Full pipeline run on merge to main
│
├── ingestion/
│   ├── load_csv_to_snowflake.py     # Python script: CSVs → Snowflake RAW
│   └── requirements.txt             # pandas, snowflake-connector-python
│
├── dbt/
│   ├── dbt_project.yml              # Project config + materializations
│   ├── packages.yml                 # dbt_utils, dbt_expectations
│   ├── profiles.yml.example         # Snowflake connection template
│   ├── seeds/
│   │   └── product_categories.csv   # Portuguese → English category names
│   ├── models/
│   │   ├── staging/                 # 5 views: type casting + renaming
│   │   ├── intermediate/            # 2 views: joins + business logic
│   │   └── marts/                   # 2 tables: mart_sales, mart_products
│   ├── tests/                       # 2 singular data quality tests
│   ├── macros/                      # surrogate key + performance tier macros
│   ├── snapshots/                   # SCD Type 2 orders tracking
│   └── analyses/                    # Ad-hoc revenue trend SQL
│
├── dagster/
│   ├── setup.py
│   ├── workspace.yaml
│   └── ecommerce_pipeline/
│       ├── __init__.py              # Dagster Definitions (assets + schedules)
│       ├── assets.py                # 6 Dagster assets
│       ├── schedules.py             # Daily + weekly schedules
│       └── resources.py             # DbtCliResource config
│
├── docker-compose.yml               # Dagster webserver + daemon + Metabase
├── Makefile                         # Convenience commands
├── .env.example                     # Credential template (copy → .env)
└── .gitignore                       # Excludes .env, dbt/target, venv
```

---

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/mkhamisi2007/ecommerce-analytics-pipeline.git
cd ecommerce-analytics-pipeline

# Copy and fill in your Snowflake credentials
cp .env.example .env
```

Edit `.env`:
```env
SNOWFLAKE_ACCOUNT=your_account.region.aws
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_DATABASE=ECOMMERCE_DB
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
```

### 2. Create dbt profiles.yml

```bash
cp dbt/profiles.yml.example dbt/profiles.yml
```

Open `dbt/profiles.yml` and fill in your Snowflake credentials. This file is gitignored and never committed.

### 3. Load environment variables

```bash
source .env
```

Run this in your terminal before using any `make` command or running dbt manually. It exports your Snowflake credentials into the shell session.

> **Tip:** Add it to your shell startup (`~/.zshrc`) or re-run it each time you open a new terminal in this project.

### 4. Set up Python environment

```bash
# Create virtual environment with Python 3.11
python3.11 -m venv .venv
source .venv/bin/activate   # Mac/Linux

# Install all dependencies
make install
```

### 5. Place Olist CSV files

Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place the CSV files inside the `kaggle-data/` folder in the project root:

```
ecommerce-analytics-pipeline/      ← project root
├── kaggle-data/                    ← put CSV files here
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_customers_dataset.csv
│   ├── olist_products_dataset.csv
│   └── olist_order_reviews_dataset.csv
├── ingestion/
├── dbt/
└── ...
```

> The CSV files (~120 MB total) are included in the repository so you can clone and run the pipeline immediately without downloading from Kaggle.

### 6. Load data into Snowflake

```bash
make ingest
```

The script will **automatically create the database** (`ECOMMERCE_DB`) and the `RAW` schema if they do not exist yet — no manual Snowflake setup required.

Expected output:
```
Database 'ECOMMERCE_DB' ready.
Schema 'RAW' ready.
Loading olist_orders_dataset.csv      → RAW.ORDERS      ... done (99,441 rows)
Loading olist_order_items_dataset.csv → RAW.ORDER_ITEMS ... done (112,650 rows)
Loading olist_customers_dataset.csv   → RAW.CUSTOMERS   ... done (99,441 rows)
Loading olist_products_dataset.csv    → RAW.PRODUCTS    ... done (32,951 rows)
Loading olist_order_reviews_dataset.csv → RAW.REVIEWS   ... done (99,224 rows)
All tables loaded successfully.
```

### 7. Run the dbt pipeline

```bash
make dbt-deps      # Install dbt packages (dbt_utils, dbt_expectations)
make dbt-seed      # Load product category lookup table
make dbt-run       # Build all 9 models (staging → intermediate → marts)
make dbt-test      # Run 51 data quality tests
make dbt-snapshot  # Create SCD Type 2 snapshot of orders
```

Or run everything in one command:

```bash
make all
```

---

## dbt Models Explained

### Staging Layer (`dbt_dev_staging` schema — views)

Light-touch cleaning. Each model maps 1:1 to a raw table.

| Model | Source | Key transformations |
|-------|--------|---------------------|
| `stg_orders` | `RAW.ORDERS` | Rename columns to snake_case, cast timestamps to `date`, lowercase `order_status` |
| `stg_order_items` | `RAW.ORDER_ITEMS` | Cast `price` and `freight_value` to `numeric(10,2)`, compute `total_item_price` |
| `stg_customers` | `RAW.CUSTOMERS` | Lowercase city, uppercase state |
| `stg_products` | `RAW.PRODUCTS` | Lowercase category name, cast weight/dimensions |
| `stg_reviews` | `RAW.REVIEWS` | Cast `review_score` to integer, cast date |

### Intermediate Layer (`dbt_dev_intermediate` schema — views)

Business logic and joins. Never exposed directly to BI tools.

**`int_orders_with_customers`**
- Joins `stg_orders` + `stg_order_items` + `stg_customers`
- Calculates `days_to_deliver`
- Adds `is_late` boolean (NULL for undelivered orders, true/false for delivered)
- One row per order with customer location attached

**`int_product_performance`**
- Joins `stg_order_items` + `stg_products` + `stg_reviews`
- Groups by `product_id`
- Calculates `total_revenue`, `total_units_sold`, `avg_review_score`, `return_rate`

### Mart Layer (`dbt_dev_marts` schema — tables)

Final analytics-ready tables. These are what BI tools and stakeholders query.

---

## Mart Tables — What's Inside

### `MART_SALES` — 22 rows (one per month)

Monthly business performance summary.

| Column | Type | Description |
|--------|------|-------------|
| `sales_id` | varchar | Surrogate key (MD5 hash of month) |
| `month` | date | First day of the month |
| `total_revenue` | numeric(14,2) | Sum of all order values for the month |
| `total_orders` | integer | Number of distinct orders |
| `average_order_value` | numeric(10,2) | `total_revenue / total_orders` |
| `on_time_delivery_rate` | numeric(5,4) | % of delivered orders that arrived on time (0.0–1.0) |
| `new_customers` | integer | Distinct customers who ordered that month |

Sample query:
```sql
SELECT
    month,
    total_revenue,
    total_orders,
    ROUND(on_time_delivery_rate * 100, 1) AS on_time_pct
FROM ECOMMERCE_DB.DBT_DEV_MARTS.MART_SALES
ORDER BY month;
```

---

### `MART_PRODUCTS` — 32,951 rows (one per product)

Per-product performance metrics with revenue tier classification.

| Column | Type | Description |
|--------|------|-------------|
| `product_id` | varchar | Primary key |
| `product_category` | varchar | Product category (English from seed) |
| `total_revenue` | numeric(10,2) | Total revenue generated by this product |
| `total_units_sold` | integer | Number of orders containing this product |
| `avg_review_score` | numeric(4,2) | Average customer rating (1–5) |
| `return_rate` | numeric(5,4) | % of orders with review score ≤ 2 |
| `performance_tier` | varchar | `high` (>10k revenue), `medium` (2k–10k), `low` (<2k) |

Sample query:
```sql
SELECT
    product_category,
    COUNT(*) AS product_count,
    ROUND(SUM(total_revenue), 2) AS category_revenue,
    ROUND(AVG(avg_review_score), 2) AS avg_score
FROM ECOMMERCE_DB.DBT_DEV_MARTS.MART_PRODUCTS
GROUP BY product_category
ORDER BY category_revenue DESC
LIMIT 10;
```

---

## Accessing Your Data — 3 Ways

### 1. Snowflake Snowsight (browser, no setup)

Go to `https://zi32238.eu-west-3.aws.snowflakecomputing.com`

Log in → **Worksheets** → run SQL against:
- `ECOMMERCE_DB.DBT_DEV_MARTS.MART_SALES`
- `ECOMMERCE_DB.DBT_DEV_MARTS.MART_PRODUCTS`

### 2. Metabase Dashboard (Docker, port 3001)

```bash
make metabase-up
```

Open **`http://localhost:3001`** and complete the setup wizard:

1. Click **"Let's get started"**
2. Create an admin account (local only)
3. Choose **Snowflake** as the database type
4. Fill in connection details:

| Field | Value |
|-------|-------|
| Account | `your_account.region.aws` |
| User | your Snowflake username |
| Password | your Snowflake password |
| Database | `ECOMMERCE_DB` |
| Warehouse | `COMPUTE_WH` |
| Schema | `DBT_DEV_MARTS` |

5. After connecting: **Browse → Databases → Ecommerce Pipeline → DBT_DEV_MARTS**
6. Click any table → **"Visualize"** to build charts instantly

Suggested dashboards to build:
- **Monthly Revenue Trend** — line chart on `MART_SALES.total_revenue` by `month`
- **On-Time Delivery Rate** — line chart on `on_time_delivery_rate` by `month`
- **Top Product Categories** — bar chart: `MART_PRODUCTS` grouped by `product_category`, sum of `total_revenue`
- **Performance Tier Distribution** — pie chart on `performance_tier`
- **Low-Rated Products** — table of products where `avg_review_score < 3`

### 3. dbt Docs (lineage graph + data dictionary)

```bash
make dbt-docs
```

Open **`http://localhost:8080`** to see:
- Full DAG lineage graph (sources → staging → intermediate → marts)
- Column-level descriptions for every model
- Test results per column

---

## Dagster Orchestration UI

```bash
make dagster-up
```

Open **`http://localhost:3000`**

### Asset Graph

Six assets in two groups:

```
[ingestion]
raw_data_ingestion
       │
       ▼
[dbt]
dbt_staging ──────────────────┐
       │                      ▼
       ▼               dbt_snapshot
dbt_intermediate
       │
       ▼
 dbt_marts
       │
       ▼
  dbt_tests
```

### Schedules

| Schedule | Cron | What it runs |
|----------|------|-------------|
| `daily_pipeline_06_utc` | `0 6 * * *` | Full pipeline: ingest → staging → intermediate → marts → tests |
| `weekly_snapshot_monday_07_utc` | `0 7 * * 1` | dbt snapshot (SCD Type 2 for orders) |

### Running manually

1. Go to **Assets** tab
2. Select all assets (or specific ones)
3. Click **"Materialize selected"**
4. Watch logs in real time in the **Runs** tab

---

## CI/CD — GitHub Actions

Two workflows run automatically:

### On Pull Request → `main`

File: `.github/workflows/dbt_test_on_pr.yml`

```
Checkout → Python 3.11 → pip install dbt-snowflake
→ dbt deps → dbt compile → dbt test --select staging
```

Catches breaking changes before they merge.

### On Merge → `main`

File: `.github/workflows/dbt_run_on_merge.yml`

```
Checkout → Python 3.11 → pip install dbt-snowflake
→ dbt deps → dbt seed → dbt run → dbt test → dbt snapshot
→ (on failure) Slack notification via webhook
```

Requires GitHub Secrets:
- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`
- `SNOWFLAKE_PASSWORD`
- `SNOWFLAKE_DATABASE`
- `SNOWFLAKE_WAREHOUSE`
- `SLACK_WEBHOOK_URL` (optional, for failure alerts)

---

## Makefile Reference

```bash
make install        # pip install ingestion deps + dagster package
make ingest         # Load Kaggle CSVs into Snowflake RAW schema
make dbt-deps       # Install dbt packages from packages.yml
make dbt-seed       # Load seed CSV (product categories)
make dbt-run        # Build all 9 dbt models
make dbt-test       # Run 51 data quality tests
make dbt-snapshot   # Run SCD Type 2 snapshot on orders
make dbt-docs       # Generate + serve dbt documentation (port 8080)
make dagster-up     # Start Dagster webserver + daemon (port 3000)
make metabase-up    # Start Metabase BI dashboard (port 3001)
make all            # ingest + dbt-deps + dbt-seed + dbt-run + dbt-test
```

---

## Data Quality Tests

51 tests run automatically with `make dbt-test`:

| Test type | Count | Examples |
|-----------|-------|---------|
| `not_null` | 20 | All primary keys, key metrics |
| `unique` | 12 | `order_id`, `customer_id`, `product_id`, `sales_id` |
| `accepted_values` | 5 | `order_status` (8 valid values), `review_score` (1–5), `performance_tier` |
| `dbt_expectations` | 2 | `avg_review_score` between 1–5, `on_time_delivery_rate` between 0–1 |
| Singular (custom SQL) | 2 | No negative prices, no future order dates |

---

## SCD Type 2 — Orders Snapshot

The `orders_snapshot` tracks changes to `order_status` and `order_delivered_date` over time, enabling historical analysis of how orders progress through the pipeline.

```sql
-- See full history of a specific order
SELECT order_id, order_status, order_delivered_date,
       dbt_valid_from, dbt_valid_to
FROM ECOMMERCE_DB.SNAPSHOTS.ORDERS_SNAPSHOT
WHERE order_id = 'some-order-id'
ORDER BY dbt_valid_from;
```

---

## Ports Reference

| Service | URL | Purpose |
|---------|-----|---------|
| Dagster UI | `http://localhost:3000` | Pipeline orchestration + monitoring |
| Metabase | `http://localhost:3001` | BI dashboards |
| dbt docs | `http://localhost:8080` | Data lineage + documentation |
| Snowflake | `https://zi32238.eu-west-3.aws.snowflakecomputing.com` | Direct SQL access |

---

## License

MIT
