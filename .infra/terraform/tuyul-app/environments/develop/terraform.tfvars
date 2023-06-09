app_name    = "tuyul"
env         = "develop"
owner       = "platform"
app_version = "latest-dev"

infra_state_secret_name = "dev/tf/wmp-infra"

dockerhub_secret_name = "infra/common/docker-hub-creds"
container_registry    = "w19andrian"
container_port        = 3000

cf_secret_name     = "infra/common/cloudflare"
acme_email_address = "wempiandrian@gmail.com"

cf_dns_zone = "wmp19.xyz"

