terraform {
  backend "s3" {
    # Use CI/CD variables for this
    bucket         = "tf-state-backend-bucket-name" 
    key            = "shared-network.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}