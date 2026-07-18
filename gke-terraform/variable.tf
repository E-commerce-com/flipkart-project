variable "project" {
  description = "GCP project ID"
  type        = string
  default     = "project-73bd9651-4490-4776-91a"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-south1-a"
}

variable "k8s_version" {
  description = "GKE Kubernetes version"
  type        = string
  default     = "1.31.6-gke.1020000"
}
