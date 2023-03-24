variable "app_name" {
  description = "The name of the app"
  type        = string
}

variable "owner" {
  description = "Owner of this application(department, squad, etc)"
  type        = string
}

variable "infra_state_secret_name" {
  description = "AWS Secret Manager - secret name of core infra Terraform backend"
  type        = string
}

variable "cf_secret_name" {
  description = "AWS Secret Manager - secret name of Cloudflare's credentials"
  type        = string
}

variable "dockerhub_secret_name" {
  description = "AWS Secret Manager - secret name of Docker Hub credentials"
  type        = string
}

variable "app_version" {
  description = "version of the app"
  type        = string
  default     = "latest"
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

variable "container_port" {
  description = "Container port of the app"
  type        = number
  default     = 80
}

variable "container_registry" {
  description = "registry name of the container image"
  type        = string
  default     = ""
}

variable "cf_dns_zone" {
  description = "DNS zone name"
  type        = string
  default     = "wmp19.xyz"
}

variable "desired_instance_count" {
  description = "desired number of ECS task instances"
  type        = number
  default     = 1
}

variable "acme_email_address" {
  description = "email address for acme registration (to get SSL cert from LetsEncrypt)"
  type        = string
  default     = ""
}

variable "lb_deletion_protection_enabled" {
  description = "enable ALB deletion protection"
  type        = string
  default     = false
}
