variable "project" {
  description = "Google Cloud Project ID"
  type        = string
  default     = "project-73bd9651-4490-4776-91a"
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "Google Cloud Zone"
  type        = string
  default     = "asia-south1-a"
}

variable "K8s_version" {
  description = "GKE Kubernetes Version"
  type        = string
  default     = "1.31.6-gke.1020000"
}
