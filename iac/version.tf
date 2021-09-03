terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.52.0"
    }
    
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.11.3"
    }
  }
}