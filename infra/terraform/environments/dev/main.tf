terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name        = "${local.name_prefix}-eks-cluster"
  cluster_version     = "1.29"
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids

  node_instance_type  = "t3.medium"
  desired_size        = 2
  max_size            = 3
  min_size            = 1

  tags                = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  eks_node_security_group_id = module.eks.node_security_group_id

  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password

  tags                = local.common_tags
}
