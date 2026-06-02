from dagster import ScheduleDefinition, define_asset_job, AssetSelection

full_pipeline_job = define_asset_job(
    name="full_pipeline_job",
    selection=AssetSelection.groups("ingestion", "dbt"),
)

snapshot_job = define_asset_job(
    name="snapshot_job",
    selection=AssetSelection.assets("dbt_snapshot"),
)

daily_pipeline_schedule = ScheduleDefinition(
    name="daily_pipeline_06_utc",
    cron_schedule="0 6 * * *",
    job=full_pipeline_job,
    execution_timezone="UTC",
)

weekly_snapshot_schedule = ScheduleDefinition(
    name="weekly_snapshot_monday_07_utc",
    cron_schedule="0 7 * * 1",
    job=snapshot_job,
    execution_timezone="UTC",
)
