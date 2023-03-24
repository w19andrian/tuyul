locals {
  default_tags = {
    terraform   = "true"
    environment = var.env
    app_name    = local.full_app_name
    owner       = var.owner
    version     = var.app_version
  }
  full_app_name = "${random_string.suffix.keepers.app_name}-${local.env_alias}-${random_string.suffix.id}"
  user_def_tags = merge(local.default_tags, var.user_tags)

  env_map = {
    develop     = "dev"
    development = "dev"
    staging     = "stg"
    beta        = "beta"
    production  = "prod"
  }
  env_alias = join("", [for k, v in local.env_map : v if k == var.env])
}
# ================================================= #
resource "random_string" "suffix" {
  keepers = {
    "app_name" = var.app_name
  }
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "this" {
  length = 16

  keepers = {
    "app_name" = local.full_app_name
  }
}
resource "aws_memorydb_user" "this" {
  user_name     = random_password.this.keepers.app_name
  access_string = "on ~* &* +@all"

  authentication_mode {
    type      = "password"
    passwords = [random_password.this.result]
  }
}
# =============================================== #
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
  default     = "develop"
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
# =============================================== #
output "username" {
  value = aws_memorydb_user.this.id
}

output "password" {
  sensitive = true
  value     = aws_memorydb_user.this.authentication_mode[0].passwords
}

output "username_arn" {
  value = aws_memorydb_user.this.arn
}
