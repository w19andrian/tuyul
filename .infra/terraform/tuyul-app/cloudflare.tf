locals {
  cf_secrets_decoded = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)
}

data "aws_secretsmanager_secret" "this" {
  name = "infra/common/cloudflare"
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.this.id
}

data "cloudflare_zone" "this" {
  account_id = local.cf_secrets_decoded["account_id"]
  name       = var.cf_dns_zone
}

resource "cloudflare_record" "this" {
  zone_id = data.cloudflare_zone.this.id
  name    = var.app_name
  value   = aws_lb.this.dns_name
  type    = "CNAME"
  ttl     = 3600
  proxied = false

}