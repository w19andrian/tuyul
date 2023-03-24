app_name = "tuyul"
env      = "production"
owner    = "platform"

infra_state_secret_name = "prod/tf/wmp-infra"

dockerhub_secret_name = "infra/common/docker-hub-creds"
container_registry    = "w19andrian"
container_port        = 80

cf_dns_zone = "wmp19.xyz"

cf_secret_name     = "infra/common/cloudflare"
acme_email_address = "wempiandrian@gmail.com"

lb_deletion_protection_enabled = true
