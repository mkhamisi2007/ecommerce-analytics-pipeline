.PHONY: install ingest dbt-deps dbt-seed dbt-run dbt-test dbt-snapshot dbt-docs dagster-up metabase-up all

install:
	pip install -r ingestion/requirements.txt
	pip install -e dagster/

ingest:
	python ingestion/load_csv_to_snowflake.py

dbt-deps:
	cd dbt && dbt deps

dbt-seed:
	cd dbt && dbt seed

dbt-run:
	cd dbt && dbt run

dbt-test:
	cd dbt && dbt test

dbt-snapshot:
	cd dbt && dbt snapshot

dbt-docs:
	cd dbt && dbt docs generate && dbt docs serve

dagster-up:
	docker compose up dagster-webserver dagster-daemon -d

metabase-up:
	docker compose up metabase -d

all: ingest dbt-deps dbt-seed dbt-run dbt-test
