variable "vpc_cidr_block" {
  description = "The CIDR block for the entire shared VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

# Each element defines a subnet and its associated environment tag.
variable "all_subnets" {
  description = "A list of maps defining all subnets to be created across all environments"
  type = list(object({
    cidr_block  = string
    tier        = string # "Public" or "Private"
    environment = string # "dev", "stage", or "prod"
  }))
  default = [
    # Dev subnets
    { cidr_block = "10.0.1.0/24", tier = "Public", environment = "dev" },
    { cidr_block = "10.0.2.0/24", tier = "Public", environment = "dev" },
    { cidr_block = "10.0.101.0/24", tier = "Private", environment = "dev" },
    { cidr_block = "10.0.102.0/24", tier = "Private", environment = "dev" },

    # Stage subnets
    { cidr_block = "10.0.3.0/24", tier = "Public", environment = "stage" },
    { cidr_block = "10.0.4.0/24", tier = "Public", environment = "stage" },
    { cidr_block = "10.0.103.0/24", tier = "Private", environment = "stage" },
    { cidr_block = "10.0.104.0/24", tier = "Private", environment = "stage" },

    # Production subnets
    { cidr_block = "10.0.5.0/24", tier = "Public", environment = "prod" },
    { cidr_block = "10.0.6.0/24", tier = "Public", environment = "prod" },
    { cidr_block = "10.0.105.0/24", tier = "Private", environment = "prod" },
    { cidr_block = "10.0.106.0/24", tier = "Private", environment = "prod" },
  ]
}