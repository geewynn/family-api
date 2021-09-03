provider "google" {
  project = var.project_id
  region = var.region
  credentials = "${file("creds.json")}"
}


provider "google-beta" {
  project = var.project_id
  region = var.region
  credentials = "${file("creds.json")}"
}

data "google_client_config" "gcp_client" {
  provider = google
}

provider "kubernetes" {

  host                   = google_container_cluster.primary.endpoint
  token                  = data.google_client_config.gcp_client.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.primary.endpoint
    token                  = data.google_client_config.gcp_client.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
    }
}

provider "kubectl" {
  host                   = google_container_cluster.primary.endpoint
  token                  = data.google_client_config.gcp_client.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }