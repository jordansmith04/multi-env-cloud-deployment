terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "governance" {
  source = "../../modules/governance"

  environment        = "stage"
  budget_limit       = var.env_budget_limit
  iam_access_name    = "DevOps-Engineer" # Less privileged role than Admin
  # In a real setup, this would be a list of trusted account IDs.
  allowed_account_ids = [var.allowed_iam_account_id]
}

module "app_service" {
  source = "../../modules/app-service"

  environment = "stage"

  vpc_id              = data.aws_vpc.shared.id
  public_subnet_ids   = data.aws_subnets.public.ids
  private_subnet_ids  = data.aws_subnets.private.ids

  app_image_tag = var.app_image_tag
  app_port      = 8080
  
  fargate_cpu    = var.env_fargate_cpu
  fargate_memory = var.env_fargate_memory
}
