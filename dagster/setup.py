from setuptools import find_packages, setup

setup(
    name="ecommerce_pipeline",
    packages=find_packages(exclude=["ecommerce_pipeline_tests"]),
    install_requires=[
        "dagster",
        "dagster-webserver",
        "dagster-dbt",
        "dbt-snowflake",
        "python-dotenv",
    ],
    extras_require={
        "dev": [
            "dagster-webserver",
            "pytest",
        ]
    },
)
