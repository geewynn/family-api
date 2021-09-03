resource "google_container_cluster" "primary" {
  name     = "gke-${var.project_id}-cluster"
  location = var.zone
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary" {
  name       = "new-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    labels = {
      env = var.project_id
    }

    
    # preemptible  = true
    machine_type = "e2-medium"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }


  }
}