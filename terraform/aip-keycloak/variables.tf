variable "keycloak_url" {
  description = "Base URL of the Keycloak v24+ deployment. Do not include the legacy /auth path."
  type        = string
}

variable "keycloak_client_id" {
  description = "Admin client ID used by Terraform to configure AIP realms."
  type        = string
  default     = "terraform-admin"
}

variable "environments" {
  description = "AIP environments. Each environment maps to exactly one Keycloak realm named aip-{environment}."
  type        = set(string)
  default     = ["dev", "staging", "prod"]

  validation {
    condition     = alltrue([for environment in var.environments : can(regex("^[a-z][a-z0-9-]*$", environment))])
    error_message = "Environment names must be lowercase DNS-label compatible strings."
  }
}

variable "client_access_type" {
  description = "Access type for platform agent OIDC clients. Must remain CONFIDENTIAL for service-account client credentials."
  type        = string
  default     = "CONFIDENTIAL"

  validation {
    condition     = var.client_access_type == "CONFIDENTIAL"
    error_message = "AIP platform agents must be confidential clients."
  }
}
