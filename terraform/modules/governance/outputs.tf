output "iam_role_arn" {
  description = "The ARN of the IAM Role created for environment access control"
  value       = aws_iam_role.env_access.arn
}

output "budget_sns_topic_arn" {
  description = "The ARN of the SNS Topic used for budget alerts"
  value       = aws_sns_topic.budget_alerts.arn
}