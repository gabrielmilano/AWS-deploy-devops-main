output "html_app_alb_dns_name" {
  description = "The DNS name of the HTML Application Load Balancer"
  value       = aws_lb.strapi_alb.dns_name
}

output "html_app_cluster_name" {
  description = "The name of the ECS cluster for HTML app"
  value       = aws_ecs_cluster.strapi_cluster.name
}

output "html_app_service_name" {
  description = "The name of the ECS service for HTML app"
  value       = aws_ecs_service.strapi_service.name
}