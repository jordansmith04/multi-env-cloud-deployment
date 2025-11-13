# SNS Topic for Budget Alerts
resource "aws_sns_topic" "budget_alerts" {
  name = "${var.environment}-BudgetAlerts"

  tags = {
    Environment = var.environment
  }
}

# SNS Subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  for_each  = toset(var.notification_emails)
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = each.value 
}

# AWS Budget by Environment Tag
resource "aws_budgets_budget" "environment_cost" {
  name         = "${var.environment}-Monthly-Limit"
  budget_type  = "COST"
  limit_amount = var.budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Filter the budget to only track costs associated with the environment
  cost_filter {
    name   = "TagKeyValue"
    values = ["user:Environment$${var.environment}"]
  }

  notification {
    comparison_operator = "GREATER_THAN"
    notification_type   = "ACTUAL"
    threshold           = 80 # Alert at 80% of the budget
    threshold_type      = "PERCENTAGE"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }

  tags = {
    Environment = var.environment
  }
}

# Role-Based IAM Segregation

# IAM Role Definition
# Role assumed by users/services in the allowed accounts.
resource "aws_iam_role" "env_access" {
  name = "${var.environment}-${var.iam_access_name}-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = var.allowed_account_ids
        },
        Condition = {}
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Policy Document
data "aws_iam_policy_document" "env_restriction_policy" {
  statement {
    sid    = "AllowGeneralReadonly"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "logs:Get*",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "ecr:GetAuthorizationToken",
      "ecr:Describe*",
      "ecs:Describe*",
      "iam:List*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowFullAccessToEnvironmentResources"
    effect = "Allow"
    actions = [
      "*" # All actions, restricted by environment tag
    ]
    resources = ["*"] 

    condition {
      # Restrict actions only to resources tagged with the environment name
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }
  }

  statement {
    sid    = "AllowS3BackendAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    # Update this with the ARN of your S3 state backend bucket
    resources = [
      "arn:aws:s3:::<YOUR-S3-STATE-BUCKET-NAME>/*",
      "arn:aws:s3:::<YOUR-S3-STATE-BUCKET-NAME>"
    ]
  }
}

# Attaching the policy to the role
resource "aws_iam_role_policy" "env_restriction" {
  name   = "${var.environment}-RestrictionPolicy"
  role   = aws_iam_role.env_access.id
  policy = data.aws_iam_policy_document.env_restriction_policy.json
}