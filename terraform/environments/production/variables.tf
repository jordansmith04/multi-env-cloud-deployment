variable "env_budget_limit" {
  description = "The monthly budget limit for this environment"
  type        = number
  default     = 500.00 # USD
}

variable "allowed_iam_account_id" {
  description = "The root account ID allowed to assume the DevOps role"
  type        = string
  default     = "123456789012" # Placeholder
}

variable "env_fargate_cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 1024 # double stage env
}

variable "env_fargate_memory" {
  description = "Fargate memory in MB"
  type        = number
  default     = 2048 # double stage env
}

variable "region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "us-east-1" # Placeholder
}

variable "app_image_tag" {
  description = "The Docker image tag (commit SHA) to deploy from ECR"
  type        = string
  default     = "latest" # Placeholder
}