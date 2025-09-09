output "ecs_cluster_id" {
  value = aws_ecs_cluster.fastapi_cluster.id
}

output "ecs_service_name" {
  value = aws_ecs_service.fastapi_service.name
}
