variable "app_name" {
  description = "The name of the app"
  type        = string
}

variable "app_version" {
  description = "version of the app"
  type        = string
  default     = "latest"
}

variable "owner" {
  description = "Owner of this application(department, squad, etc)"
  type        = string
}

variable "env" {
  description = "Environment where this app is going to be deployed"
  type        = string
  default     = "staging"
}

variable "user_tags" {
  description = "Additional tags for all the resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
