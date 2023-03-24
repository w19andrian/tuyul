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

  image_name = (var.container_registry != null) || (var.container_registry != "") ? "${var.container_registry}/${var.app_name}:${var.app_version}" : "${var.app_name}:${var.app_version}"

  env_map = {
    develop     = "dev"
    development = "dev"
    staging     = "stg"
    beta        = "beta"
    production  = "prod"
  }
  env_alias = join("", [for k, v in local.env_map : v if k == var.env])
}
# ====================================================== #
data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = "wmp-tf-state"
    key    = "${var.env}/ops/ecs_cluster/state"
    region = var.region
  }
}
# ====================================================== #
resource "random_string" "suffix" {
  keepers = {
    "app_name" = var.app_name
  }
  length  = 6
  upper   = false
  special = false
}
