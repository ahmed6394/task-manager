# Terraform Infrastructure — EKS + RDS + IAM

## Overview

This Terraform setup provisions a production-ready dev environment on AWS using three modules: EKS (Kubernetes cluster), RDS (PostgreSQL), and IAM (Load Balancer Controller role). All modules are wired together in `environments/dev/`.

---

## Directory Structure

```text
infra/terraform/
  environments/
    dev/
      main.tf               # wires all modules together
      variables.tf
      outputs.tf
      backend.tf
      terraform.tfvars      # git-ignored, holds secrets
  modules/
    eks/                    # EKS cluster + node group + OIDC
    rds/                    # PostgreSQL RDS instance
    iam/                    # IAM role for Load Balancer Controller
```

---

## Modules

### EKS (`modules/eks`)

Creates:
- EKS cluster (`aws_eks_cluster`)
- Managed node group (`aws_eks_node_group`) — `t3.medium`, scaling 1/2/3
- Cluster IAM role + node IAM role with required policy attachments
- Cluster security group + worker node security group with correct ingress/egress rules
- OIDC provider (`aws_iam_openid_connect_provider`) for IRSA support

Key outputs:
| Output | Description |
|---|---|
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | API server endpoint |
| `cluster_certificate_authority_data` | CA data for kubeconfig |
| `oidc_provider_arn` | OIDC ARN for IAM role trust policies |
| `oidc_provider_url` | OIDC URL (without `https://`) |
| `cluster_security_group_id` | Cluster control plane SG |
| `node_security_group_id` | Worker node SG — passed to RDS |

---

### RDS (`modules/rds`)

Creates:
- DB subnet group (private subnets only)
- RDS security group — allows port `5432` **only** from the EKS worker node security group
- PostgreSQL RDS instance (`engine_version = "16"`)

Key configuration:
- `publicly_accessible = false`
- `multi_az = false` — set to `true` for prod
- `skip_final_snapshot = true` — set to `false` for prod
- `deletion_protection = false` — set to `true` for prod

Key outputs:
| Output | Description |
|---|---|
| `rds_endpoint` | RDS host address |
| `rds_port` | PostgreSQL port (5432) |
| `database_name` | Database name |

---

### IAM (`modules/iam`)

Creates:
- IAM role for AWS Load Balancer Controller with OIDC trust policy scoped to `system:serviceaccount:kube-system:aws-load-balancer-controller`
- IAM policy with required ELB, EC2, ACM, WAF permissions
- Policy attachment

Key outputs:
| Output | Description |
|---|---|
| `lbc_role_arn` | Role ARN to annotate the LBC service account |

---

## Wiring (`environments/dev/main.tf`)

```hcl
module "eks" {
  source             = "../../modules/eks"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  tags               = local.tags
}

module "rds" {
  source                     = "../../modules/rds"
  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = var.vpc_id
  private_subnet_ids         = var.private_subnet_ids
  eks_node_security_group_id = module.eks.node_security_group_id
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  tags                       = local.tags
}

module "iam" {
  source            = "../../modules/iam"
  project_name      = var.project_name
  environment       = var.environment
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = replace(module.eks.oidc_provider_url, "https://", "")
  tags              = local.tags
}
```

---

## Credentials

Never hardcode `db_username` or `db_password`. Use one of:

**Option A — `terraform.tfvars` (local dev only)**
```hcl
vpc_id = "vpc-xxxxxxxxxxxxxxxxx"

private_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy"
]

db_username = "todoapp"
db_password = "changeme123"
```
Ensure `.gitignore` contains:
```
*.tfvars
!*.tfvars.example
```

**Option B — AWS Secrets Manager (recommended)**
```bash
aws secretsmanager create-secret \
  --name "todo-list/dev/db" \
  --secret-string '{"username":"todoapp","password":"changeme123"}'
```
Then reference in Terraform:
```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "todo-list/dev/db"
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}
```

---

## Deployment

```bash
cd infra/terraform/environments/dev

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

---

## Prod Checklist

Before promoting to `environments/prod`, change these values:

- [ ] `multi_az = true` in RDS module
- [ ] `skip_final_snapshot = false` in RDS module
- [ ] `deletion_protection = true` in RDS module
- [ ] Use AWS Secrets Manager for credentials (not `tfvars`)
- [ ] Restrict `public_access_cidrs` on EKS cluster
- [ ] Enable EKS control plane logging