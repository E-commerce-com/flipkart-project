variable "project" {
  description = "this is gcp project-id"
  type        = string
  default     = "project-73bd9651-4490-4776-91a"
}

variable "region" {
  description = "this is gcp region"
  type        = string
  default     = "asia-south1-a"
}

variable "zone" {
  description = "this is gcp zone"
  type        = string
  default     = "asia-south1-a"
}

variable "K8s_version" {
  description = "this is the gke version"
  type        = string
  default     = "1.31.6-gke.1020000"
}
