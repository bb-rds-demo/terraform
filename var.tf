# For CICD deployments leave AWS access key/secret defaults blank, and set dynamically via pipeline.

variable "AWS_ACCESS_KEY" {
  type        = string
  default     = ""
  description = "AWS access key. Set dynamically by pipeline."
  sensitive   = true
}

variable "AWS_SECRET_KEY" {
  type        = string
  default     = ""
  description = "AWS secret key. Set dynamically by pipeline."
  sensitive   = true
}