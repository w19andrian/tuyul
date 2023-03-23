output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs.cluster_arn
}

output "ecs_cluster_id" {
  description = "ECS cluster id"
  value       = module.ecs.cluster_name
}
