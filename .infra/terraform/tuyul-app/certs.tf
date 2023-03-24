resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.acme_email_address
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.registration.account_key_pem
  common_name               = data.cloudflare_zone.this.name
  subject_alternative_names = ["*.${data.cloudflare_zone.this.name}"]

  dns_challenge {
    provider = "cloudflare"

    config = {
      CF_DNS_API_TOKEN = local.cf_secrets_decoded["api_token"]
    }
  }

  depends_on = [acme_registration.registration]
}

resource "aws_acm_certificate" "this" {
  certificate_body  = acme_certificate.certificate.certificate_pem
  private_key       = acme_certificate.certificate.private_key_pem
  certificate_chain = acme_certificate.certificate.issuer_pem

  lifecycle {
    create_before_destroy = true
  }
}
