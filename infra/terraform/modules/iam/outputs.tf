output "lbc_role_arn" {
    description = "IAM role "
    value       = aws_iam_role.lbc.arn
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "IAM role ARN for GitHub Actions"
}
