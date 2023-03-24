output "ecs_cluster_arn" {
  description = "ECS cluster ARN. Id has the same value as this"
  value       = aws_ecs_cluster.this.arn
}

output "ecs_cluster_id" {
  description = "ECS cluster id"
  value       = aws_ecs_cluster.this.name
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_main_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_private_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "vpc_public_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "redis_arn" {
  value = aws_memorydb_cluster.redis.arn
}

output "redis_endpoint" {
  sensitive = true
  value     = "${aws_memorydb_cluster.redis.cluster_endpoint[0]["address"]}:${aws_memorydb_cluster.redis.cluster_endpoint[0]["port"]}"
}

output "redis_username" {
  value = module.redis_user_tuyul.username
}

output "redis_password" {
  sensitive = true
  value     = tolist(module.redis_user_tuyul.password)[0]
}

output "redis_security_group" {
  value = aws_security_group.this.id
}
