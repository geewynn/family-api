resource "google_bigquery_dataset" "default" {
  dataset_id                  = "fams"
  friendly_name               = "test"
  description                 = "This is a test description"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "parents"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = file("myschema.json")

}
