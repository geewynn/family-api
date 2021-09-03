resource "google_dataflow_flex_template_job" "famflow" {
    provider = google-beta
    name              = "data"
    project = var.project_id
    region = var.region
    container_spec_gcs_path = "gs://dataflow-templates/2021-08-16-00_RC00/flex/Kafka_to_BigQuery"
    parameters = {
        outputTableSpec = "family-11:fams.parents"
        inputTopics = "coterie"
        bootstrapServers = "34.135.71.112:9094"
    }

    depends_on = [
        google_container_node_pool.primary
    ]
}