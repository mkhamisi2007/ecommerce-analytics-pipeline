import os
from pathlib import Path
from dagster_dbt import DbtCliResource

DBT_PROJECT_DIR = Path(__file__).parent.parent.parent / "dbt"

dbt_resource = DbtCliResource(
    project_dir=str(DBT_PROJECT_DIR),
    profiles_dir=str(Path.home() / ".dbt"),
    target="dev",
)
