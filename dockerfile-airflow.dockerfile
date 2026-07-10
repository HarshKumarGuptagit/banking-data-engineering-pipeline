# Dockerfiel-airflow
FROM apache/airflow:2.9.3

# Switch to airflow user first
USER airflow 

# Initialise dbt packages
RUN pip install --no-cache-dir dbt-core dbt-snowflake