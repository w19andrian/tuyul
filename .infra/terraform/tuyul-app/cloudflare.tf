locals {
  cf_secrets_decoded = jsondecode(data.aws_secretsmanager_secret_version.cf_secrets.secret_string)
  subdomain          = var.env != "production" ? "${var.app_name}.${local.env_alias}" : var.app_name
}

data "aws_secretsmanager_secret" "cf_secrets" {
  name = var.cf_secret_name
}

data "aws_secretsmanager_secret_version" "cf_secrets" {
  secret_id = data.aws_secretsmanager_secret.cf_secrets.id
}

data "cloudflare_zone" "this" {
  account_id = local.cf_secrets_decoded["account_id"]
  name       = var.cf_dns_zone
}

resource "cloudflare_record" "this" {
  zone_id = data.cloudflare_zone.this.id
  name    = local.subdomain
  value   = aws_lb.this.dns_name
  type    = "CNAME"
  ttl     = 3600
  proxied = false

}
