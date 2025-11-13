output "alb_dns" {
  value = module.app_service.alb_dns_name
}

output "stage_iam_role_arn" {
  value = module.governance.iam_role_arn
}