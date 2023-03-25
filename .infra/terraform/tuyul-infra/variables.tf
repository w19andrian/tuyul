variable "platform_name" {
  description = "name of the platform"
  type        = string
}

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

variable "vpc_public_subnets" {
  description = "list of public subnets for the VPC"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_private_subnets" {
  description = "list of private subnets for the VPC"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "network_addr" {
  description = "network address for the subnets"
  type        = string
  default     = "10.0.0.0/16"
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "db.t4g.small"
}
