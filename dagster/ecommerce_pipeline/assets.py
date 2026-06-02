import subprocess
import sys
from pathlib import Path

from dagster import asset, AssetExecutionContext

from .resources import DBT_PROJECT_DIR

INGESTION_DIR = Path(__file__).parent.parent.parent / "ingestion"


@asset(group_name="ingestion")
def raw_data_ingestion(context: AssetExecutionContext):
    """Load Olist CSVs into Snowflake RAW schema."""
    sys.path.insert(0, str(INGESTION_DIR))
    import load_csv_to_snowflake as ingestion

    import importlib
    importlib.reload(ingestion)

    import io
    from contextlib import redirect_stdout

    buf = io.StringIO()
    with redirect_stdout(buf):
        ingestion.main()

    context.log.info(buf.getvalue())


@asset(deps=[raw_data_ingestion], group_name="dbt")
def dbt_staging(context: AssetExecutionContext):
    """Run dbt staging models."""
    _run_dbt(context, ["run", "--select", "staging"])


@asset(deps=[dbt_staging], group_name="dbt")
def dbt_intermediate(context: AssetExecutionContext):
    """Run dbt intermediate models."""
    _run_dbt(context, ["run", "--select", "intermediate"])


@asset(deps=[dbt_intermediate], group_name="dbt")
def dbt_marts(context: AssetExecutionContext):
    """Run dbt mart models."""
    _run_dbt(context, ["run", "--select", "marts"])


@asset(deps=[dbt_marts], group_name="dbt")
def dbt_tests(context: AssetExecutionContext):
    """Run all dbt tests."""
    _run_dbt(context, ["test"])


@asset(deps=[dbt_staging], group_name="dbt")
def dbt_snapshot(context: AssetExecutionContext):
    """Run dbt snapshots (SCD Type 2 for orders)."""
    _run_dbt(context, ["snapshot"])


def _run_dbt(context: AssetExecutionContext, args: list[str]):
    cmd = ["dbt"] + args + ["--project-dir", str(DBT_PROJECT_DIR)]
    context.log.info(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(DBT_PROJECT_DIR))
    context.log.info(result.stdout)
    if result.returncode != 0:
        raise RuntimeError(f"dbt command failed:\n{result.stderr}")
