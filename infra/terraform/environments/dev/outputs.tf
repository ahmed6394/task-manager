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

output "eks_cluster_name" {
  description = "Name of the EKS cluster created in the dev environment"
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster created in the dev environment"
  value = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Certificate authority data for the EKS cluster created in the dev environment"
  value = module.eks.cluster_certificate_authority_data
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster created in the dev environment"
  value = module.eks.oidc_provider_arn
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for the EKS cluster created in the dev environment"
  value = module.eks.cluster_security_group_id
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_port" {
  value = module.rds.rds_port
}

output "database_name" {
  value = module.rds.database_name
}