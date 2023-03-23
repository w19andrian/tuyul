locals {
  default_tags = {
    terraform   = "true"
    environment = var.env
    app_name    = local.full_app_name
    owner       = var.owner
    version     = var.app_version
  }
  zone_list     = ["${var.region}a", "${var.region}b", "${var.region}c"]
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

resource "random_string" "suffix" {
  keepers = {
    "app_name" = var.app_name
  }
  length  = 6
  upper   = false
  special = false
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.3"

  cluster_name = local.full_app_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.id
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.user_def_tags

}

# =============================== #
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.full_app_name}"
  retention_in_days = 7

  tags = local.user_def_tags
}
