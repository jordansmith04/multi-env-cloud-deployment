output "vpc_id" {
  description = "The ID of the created shared VPC"
  value       = aws_vpc.main.id
}