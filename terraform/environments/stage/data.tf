data "aws_vpc" "shared" {
  filter {
    name   = "tag:Name"
    values = ["Production-VPC"] 
  }
}

# Stage public subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
  filter {
    name   = "tag:Environment"
    values = ["stage"]
  }
}

# Stage private subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
  filter {
    name   = "tag:Environment"
    values = ["stage"]
  }
}