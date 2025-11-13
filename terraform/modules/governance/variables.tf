variable "environment" {
  description = "The name of the environment (e.g., dev, stage, prod). Used for tagging and policy enforcement"
  type        = string
}

variable "budget_limit" {
  description = "The maximum cost limit in USD for this environment (monthly)"
  type        = number
}

variable "notification_emails" {
  description = "Email addresses to send budget alerts to"
  type        = list(string)
  default = ["example@gmail.com", "example2@gmail.com"]
}

variable "iam_access_name" {
  description = "A name describing the access level, e.g., 'DevOps-Admin'"
  type        = string
}

variable "allowed_account_ids" {
  description = "List of AWS Account IDs that are allowed to assume this role (centralized IAM account)"
  type        = list(string)
  default     = []
}