output "aws_region" {
  description = "AWS region used by the dev environment"
  value = var.aws_region
}

output "project_name" {
  description = "Project name used for tagging and naming resources in the dev environment"
  value = var.project_name
}

output "environment" {
  description = "Environment name used for tagging and naming resources in the dev environment"
  value = var.environment
}