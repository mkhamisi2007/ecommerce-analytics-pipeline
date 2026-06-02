from dagster import Definitions

from .assets import (
    raw_data_ingestion,
    dbt_staging,
    dbt_intermediate,
    dbt_marts,
    dbt_tests,
    dbt_snapshot,
)
from .schedules import daily_pipeline_schedule, weekly_snapshot_schedule
from .resources import dbt_resource

defs = Definitions(
    assets=[
        raw_data_ingestion,
        dbt_staging,
        dbt_intermediate,
        dbt_marts,
        dbt_tests,
        dbt_snapshot,
    ],
    schedules=[
        daily_pipeline_schedule,
        weekly_snapshot_schedule,
    ],
    resources={
        "dbt": dbt_resource,
    },
)
