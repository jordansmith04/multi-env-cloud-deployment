variable "app_image_tag" {
  description = "The Docker image tag (commit SHA) to deploy from ECR"
  type        = string
}

variable "app_port" {
  description = "The port the application container exposes"
  type        = number
  default     = 80
}

variable "environment" {
  description = "The name of the environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Valid values for 'environment' are 'dev', 'staging', or 'prod'."
  }
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ECS Fargate service"
  type        = list(string)
}

variable "fargate_cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 256
}

variable "fargate_memory" {
  description = "Fargate memory in MB "
  type        = number
  default     = 512
}