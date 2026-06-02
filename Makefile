.PHONY: install ingest dbt-deps dbt-seed dbt-run dbt-test dbt-snapshot dbt-docs dagster-up metabase-up all

# Load .env so all shell commands in this Makefile have the Snowflake vars
ifneq (,$(wildcard .env))
  include .env
  export
endif

install:
	pip install -r ingestion/requirements.txt
	pip install -e dagster/

ingest:
	python ingestion/load_csv_to_snowflake.py

dbt-deps:
	cd dbt && dbt deps --profiles-dir .

dbt-seed:
	cd dbt && dbt seed --profiles-dir .

dbt-run:
	cd dbt && dbt run --profiles-dir .

dbt-test:
	cd dbt && dbt test --profiles-dir .

dbt-snapshot:
	cd dbt && dbt snapshot --profiles-dir .

dbt-docs:
	cd dbt && dbt docs generate --profiles-dir . && dbt docs serve --profiles-dir .

dagster-up:
	docker compose up dagster-webserver dagster-daemon -d

metabase-up:
	docker compose up metabase -d

all: ingest dbt-deps dbt-seed dbt-run dbt-test
