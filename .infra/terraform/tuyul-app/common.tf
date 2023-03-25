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

  image_name = (var.container_registry != null) || (var.container_registry != "") ? "${var.container_registry}/${var.app_name}:${var.app_version}" : "${var.app_name}:${var.app_version}"

  env_map = {
    develop     = "dev"
    development = "dev"
    staging     = "stg"
    beta        = "beta"
    production  = "prod"
  }
  env_alias = join("", [for k, v in local.env_map : v if k == var.env])

  core_infra_secrets = jsondecode(data.aws_secretsmanager_secret_version.core_state.secret_string)
}
# ====================================================== #
data "aws_secretsmanager_secret" "core_state" {
  name = var.infra_state_secret_name
}
data "aws_secretsmanager_secret_version" "core_state" {
  secret_id = data.aws_secretsmanager_secret.core_state.id
}
data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = local.core_infra_secrets["bucket"]
    key    = local.core_infra_secrets["key"]
    region = local.core_infra_secrets["region"]
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
# ====================================================== #
output "hostname" {
  value = "${cloudflare_record.this.name}.${data.cloudflare_zone.this.name}"
}
