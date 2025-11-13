terraform {
  backend "s3" {
    # Placeholders - use CI/CD variables for these
    bucket         = "tf-state-backend-bucket-name" 
    key            = "production.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}