variable "cluster_name" {
  description = "EKS cluster name"
  type = string
  default = "todo-list-eks-cluster"
}

variable "cluster_version" {
    description = "EKS cluster version"
    type = string
    default = "1.29"
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type = string
}

variable "private_subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type = string
  default = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of worker nodes in the EKS cluster"
  type = number
  default = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes in the EKS cluster"
  type = number
  default = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes in the EKS cluster"
  type = number
  default = 1
}

variable "tags" {
  description = "Tags to apply to the EKS cluster and worker nodes"
  type = map(string)
  default = {}
}