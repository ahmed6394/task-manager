variable "aws_region" {
  description = "AWS region to deploy resources in"
  type = string
  default = "eu-north-1"
}

variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type = string
  default = "todo-list-devops"
}

variable "environment" {
  description = "Environment name, used for tagging and naming resources"
  type = string
  default = "dev"
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type = string
}

variable "private_subnet_ids" {
  description = "List of subnet IDs for the EKS worker nodes"
  type = list(string)
}