![Banking Modern Data Stack Banner](./docs/banner.png)

# Banking Modern Data Stack Pipeline

This project is an end-to-end modern data engineering pipeline for a simulated banking domain. It demonstrates how to orchestrate data from generation (OLTP) all the way to a Data Warehouse for analytics using a robust, containerized tech stack.

## 🏗️ Architecture & Data Flow

The architecture follows a classic CDC (Change Data Capture) and ELT (Extract, Load, Transform) pattern. 

### Data Flow Diagram

```mermaid
flowchart TD
    %% Define colors and styles
    classDef generator fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef database fill:#3366cc,stroke:#fff,stroke-width:2px,color:#fff;
    classDef streaming fill:#ff9900,stroke:#fff,stroke-width:2px,color:#fff;
    classDef storage fill:#ff4d4d,stroke:#fff,stroke-width:2px,color:#fff;
    classDef warehouse fill:#29b5e8,stroke:#fff,stroke-width:2px,color:#fff;
    classDef orchestrator fill:#00a3a3,stroke:#fff,stroke-width:2px,color:#fff;
    classDef transform fill:#ff6633,stroke:#fff,stroke-width:2px,color:#fff;

    A[Python Data Generator\n(Faker)]:::generator -->|Inserts Fake Data| B[(PostgreSQL\nOLTP)]:::database
    B -->|CDC Events| C[Debezium\nKafka Connect]:::streaming
    C -->|Streams| D(Kafka Topics):::streaming
    D -->|Consumes| E[Python Consumer]:::generator
    E -->|Writes Parquet| F[(MinIO Data Lake\nS3 Compatible)]:::storage
    F -->|Extracts/Downloads| G[Airflow DAG]:::orchestrator
    G -->|Loads Data| H[(Snowflake\nData Warehouse)]:::warehouse
    H -->|Transforms| I[dbt Models\n(Analytics)]:::transform
    
    subgraph Data Generation & CDC
    A
    B
    C
    D
    end
    
    subgraph Ingestion to Data Lake
    E
    F
    end
    
    subgraph ELT & Orchestration
    G
    H
    I
    end
```

### Step-by-Step Data Flow

1. **Data Generation (The Source)**
   The pipeline starts with a Python script (`data-generator/faker_generator.py`) utilizing the `Faker` library. This acts as our source system, continuously generating synthetic banking data such as new customers, newly created accounts, and live transactions. This data is written directly into a **PostgreSQL** database, which simulates a bank's operational, highly transactional database (OLTP).

2. **Change Data Capture (CDC)**
   Instead of doing bulky batch extracts from the database, we use **Debezium**, which connects to Postgres and listens to its Write-Ahead Log (WAL). Any time an `INSERT`, `UPDATE`, or `DELETE` occurs in Postgres, Debezium instantly captures the change at a row level and pushes it as an event into an **Apache Kafka** topic. This provides real-time replication without taxing the source database.

3. **Data Ingestion to Data Lake**
   A standalone Python consumer (`consumer/kafka_to_minio.py`) continuously subscribes to these Kafka topics. As messages arrive, the consumer batches them and writes them out into **MinIO**—an S3-compatible object storage service—acting as our Data Lake. The data is saved in columnar **Parquet** format, heavily partitioned by date to optimize future read queries.

4. **Orchestration & ELT**
   **Apache Airflow** functions as the brain of the operation. We have a scheduled DAG (`minio_to_snowflake_dag.py`) that periodically runs. It connects to the MinIO Data Lake, downloads the freshly landed Parquet files, and securely loads them into **Snowflake** (our cloud Data Warehouse). 

5. **Analytics Engineering**
   Once the raw data is inside Snowflake, we use **dbt (data build tool)**. dbt connects to Snowflake and executes pre-defined SQL models. It handles the "T" in ELT by joining, cleansing, and transforming the raw JSON/Parquet tables into structured dimensional models (e.g., facts and dimensions) ready for BI dashboards and downstream analytics.

## 🛠️ Technology Stack

| Component | Technology | Purpose |
| --- | --- | --- |
| **Data Generation** | Python (Faker) | Generates synthetic customers, accounts, and transactions. |
| **Source Database** | PostgreSQL | Simulates the operational transactional database (OLTP). |
| **CDC (Change Data Capture)** | Debezium & Kafka Connect | Captures row-level changes in Postgres and streams them to Kafka. |
| **Message Broker** | Apache Kafka & Zookeeper | Scalable event streaming platform for real-time data integration. |
| **Data Lake** | MinIO | S3-compatible object storage to store raw data as Parquet files. |
| **Orchestration** | Apache Airflow | Schedules and orchestrates data loads from MinIO to Snowflake. |
| **Data Warehouse** | Snowflake | Cloud data platform where data is ingested and modeled. |
| **Data Transformation** | dbt (data build tool) | Performs the "T" in ELT, transforming raw data into analytics-ready models. |
| **Containerization** | Docker & Docker Compose | Runs all local services reliably across environments. |

## 📂 Project Structure

- `data-generator/`: Python script to generate fake banking transactions and users, storing them in PostgreSQL.
- `postgres/`: Schema initialization scripts (`schema.sql`) for PostgreSQL.
- `kafka-debezium/`: Kafka Connect configurations to listen to PostgreSQL and produce CDC streams.
- `consumer/`: A Python Kafka Consumer that reads Kafka topics and writes the data to MinIO as Parquet files.
- `docker/`: Contains Airflow configurations, plugins, logs, and DAGs (e.g., `minio_to_snowflake_dag.py`).
- `banking_dbt/`: dbt project folder containing transformations (models, tests, snapshots).
- `docker-compose.yml`: The main configuration file to spin up Zookeeper, Kafka, Debezium, Postgres, MinIO, and Airflow.

## 🚀 Getting Started

### Prerequisites

- Docker and Docker Compose
- Python 3.9+
- A Snowflake Account

### Setup Instructions

1. **Configure Environment Variables:**
   Create `.env` files where required (e.g., `data-generator`, `consumer`, Airflow environment) by copying the template or defining the necessary secrets (Postgres passwords, Snowflake credentials, MinIO keys).

2. **Start the Infrastructure:**
   Run the following command to spin up all the services (Kafka, Postgres, MinIO, Airflow, Debezium):
   ```bash
   docker-compose up -d
   ```

3. **Verify Services:**
   - **Postgres:** Available on `localhost:5432`
   - **Kafka:** Available on `localhost:9092` (Internal) and `29092` (Host)
   - **MinIO Console:** Available on `localhost:9001`
   - **Airflow Web UI:** Available on `localhost:8080`

4. **Start Data Generator:**
   Run the Python script in `data-generator/` to start feeding fake data into Postgres.
   
5. **Start Kafka Consumer:**
   Run the consumer script in `consumer/` to capture Kafka topics and dump Parquet files into MinIO.

6. **Trigger Airflow DAGs:**
   Log into the Airflow UI, enable the `minio_to_snowflake_banking` DAG to load the data from MinIO into your Snowflake warehouse.

7. **Run dbt Models:**
   Once the data is in Snowflake, navigate to `banking_dbt` and run:
   ```bash
   dbt run
   dbt test
   ```

## 📝 License

This project is licensed under the MIT License.
