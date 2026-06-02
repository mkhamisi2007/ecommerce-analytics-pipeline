import os
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from dotenv import load_dotenv

load_dotenv()

SNOWFLAKE_ACCOUNT   = os.environ["SNOWFLAKE_ACCOUNT"]
SNOWFLAKE_USER      = os.environ["SNOWFLAKE_USER"]
SNOWFLAKE_PASSWORD  = os.environ["SNOWFLAKE_PASSWORD"]
SNOWFLAKE_DATABASE  = os.environ["SNOWFLAKE_DATABASE"]
SNOWFLAKE_WAREHOUSE = os.environ["SNOWFLAKE_WAREHOUSE"]

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "kaggle-data")

TABLES = {
    "ORDERS":      "olist_orders_dataset.csv",
    "ORDER_ITEMS": "olist_order_items_dataset.csv",
    "CUSTOMERS":   "olist_customers_dataset.csv",
    "PRODUCTS":    "olist_products_dataset.csv",
    "REVIEWS":     "olist_order_reviews_dataset.csv",
}


def get_connection():
    return snowflake.connector.connect(
        account=SNOWFLAKE_ACCOUNT,
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        database=SNOWFLAKE_DATABASE,
        warehouse=SNOWFLAKE_WAREHOUSE,
    )


def ensure_schema(cur, schema: str):
    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {schema}")
    cur.execute(f"USE SCHEMA {schema}")
    print(f"Schema '{schema}' ready.")


def load_table(conn, cur, table_name: str, csv_path: str):
    print(f"Loading {csv_path} → RAW.{table_name} ...", end=" ", flush=True)
    df = pd.read_csv(csv_path)
    df.columns = [c.upper() for c in df.columns]

    cur.execute(f"DROP TABLE IF EXISTS RAW.{table_name}")

    success, nchunks, nrows, _ = write_pandas(
        conn,
        df,
        table_name=table_name,
        schema="RAW",
        auto_create_table=True,
        overwrite=True,
    )
    if success:
        print(f"done ({nrows:,} rows, {nchunks} chunk(s))")
    else:
        raise RuntimeError(f"write_pandas failed for {table_name}")


def main():
    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute(f"USE DATABASE {SNOWFLAKE_DATABASE}")
        cur.execute(f"USE WAREHOUSE {SNOWFLAKE_WAREHOUSE}")
        ensure_schema(cur, "RAW")

        for table_name, filename in TABLES.items():
            csv_path = os.path.join(DATA_DIR, filename)
            if not os.path.exists(csv_path):
                print(f"WARNING: {csv_path} not found — skipping.")
                continue
            load_table(conn, cur, table_name, csv_path)

        print("\nAll tables loaded successfully.")
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()
