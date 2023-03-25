locals {
  default_tags = {
    terraform   = "true"
    environment = var.env
    app_name    = local.full_app_name
    owner       = var.owner
    version     = var.app_version
  }
  zone_list          = ["${var.region}a", "${var.region}b", "${var.region}c"]
  full_platform_name = "${random_string.suffix_platform.keepers.platform_name}-${local.env_alias}-${random_string.suffix_platform.id}"
  full_app_name      = "${random_string.suffix.keepers.app_name}-${local.env_alias}-${random_string.suffix.id}"
  user_def_tags      = merge(local.default_tags, var.user_tags)

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

resource "random_string" "suffix_platform" {
  keepers = {
    "platform_name" = var.platform_name
  }
  length  = 6
  upper   = false
  special = false
}
# =============================== #
resource "aws_ecs_cluster" "this" {
  name = "${local.full_platform_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# =============================== #
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.full_app_name}"
  retention_in_days = 7

  tags = local.user_def_tags
}

# ================================ #
resource "aws_memorydb_cluster" "redis" {
  acl_name                 = aws_memorydb_acl.this.id
  name                     = "${local.full_app_name}-redis"
  node_type                = var.redis_node_type
  num_shards               = 1
  security_group_ids       = [aws_security_group.this.id]
  snapshot_retention_limit = 7
  subnet_group_name        = aws_memorydb_subnet_group.this.id

  tags = local.default_tags
}

resource "aws_memorydb_subnet_group" "this" {
  name       = "redis-${local.env_alias}-subnet-group"
  subnet_ids = tolist(module.vpc.private_subnets)
  tags       = local.user_def_tags
}

module "redis_user_tuyul" {
  source = "./modules/redis-credentials"

  app_name = random_string.suffix.keepers.app_name
  owner    = var.owner
  region   = var.region

  user_tags = local.user_def_tags
}

resource "aws_memorydb_acl" "this" {
  name       = "${local.full_app_name}-acl"
  user_names = [module.redis_user_tuyul.username]
}

# =============================== #
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.full_platform_name}-vpc"
  cidr = var.network_addr

  azs             = local.zone_list
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = false

  tags = local.user_def_tags
}

resource "aws_security_group" "this" {
  name        = "allow_redis-${local.env_alias}"
  description = "Allow Redis inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Redis from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.user_def_tags

}
