variable "project_name" {
  description = "Name of the project"
  type = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type = string
}

variable "tags" {
  description = "Tags to apply to the RDS instance"
  type = map(string)
  default = {}
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS instance"
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the RDS instance"
  type = string
}

variable "eks_node_security_group_id" {
  description = "Security group ID for the EKS worker nodes, used to allow communication between EKS and RDS"
  type = string
}

variable "db_name" {
  description = "Name of the RDS database"
  type = string
}

variable "db_username" {
  description = "Username for the RDS database"
  type = string
}

variable "db_password" {
  description = "Password for the RDS database"
  type = string
  sensitive = true
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type = string
  default = "db.t3.micro"
}

variable "db_engine" {
  description = "Database engine for the RDS instance"
  type = string
  default = "postgres"
}

variable "db_allocated_storage" {
  description = "Default allocated storage for the RDS instance (in GB)"
  type = number
  default = 20
}