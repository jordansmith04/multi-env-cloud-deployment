output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "ecs_cluster_name" {
  description = "The name of the created ECS cluster"
  value       = aws_ecs_cluster.main.name
}