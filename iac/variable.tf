variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "project_id" {
  default     = ""
  description = "gke project_id"
}
# variable "gke_password" {
#   default     = ""
#   description = "gke password"
# }

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "region" {
  default     = "us-central1"
  description = "gcp region"
}

variable "zone" {
  default     = "us-central1-c"
  description = "gcp zone"
}


variable "gcs_location" {
  type        = string
  description = "GCS bucket name (no gs:// prefix)."
}
