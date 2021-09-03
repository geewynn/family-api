# family-api

### Description
Streaming data pipeline to load data to from an API, passes it to the kafka consumer which inturns sends the data to kafka_bigquery flex dataflow templates, this dataflow jobs processes the data and sends them to bigquery.

### Tools
1. Go: Built a simple API in GO, API consists of 3 endpoints, 2 GET Request and ! Post Requests.
2. Kafka: Consumes messages from the API and sends to Dataflow.
3. MongoDB: NoSQL data store that saves data from the API.
4. GCP Dataflow: Consumes message from the Kafka producer and loads the data to the Bigquery data warehouse.
5. Terraform: Used for provisioning infrastructure on GCP. Kubernetes, kafka and bitnami mongodb on K8s, dataflow, bigquery.
6. Kubernetes: Deploy the API and other services.

