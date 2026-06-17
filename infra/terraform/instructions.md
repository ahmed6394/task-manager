# Step-by-Step Hands-on Terraform implementation: EKS + RDS + IAM on AWS

## Step 0: Prerequisites Checklist

You need:

- An **AWS account**
- An **IAM user** with programmatic access
- **Access Key & Secret Key**
- Terraform installed on your computer
- AWS CLI installed and configured
- An **existing VPC** with at least 2 private subnets
- **VPC ID and Subnet IDs** ready

---

## Step 1: Create an IAM User (One-Time Setup)

### In AWS Console:

1. Go to **IAM → Users → Create user**
2. Username: `terraform-user`
3. Select **Programmatic access**
4. Attach the following policies:
   - `AmazonEKSFullAccess`
   - `AmazonS3FullAccess`
   - `AmazonEC2FullAccess`
   - `AmazonRDSFullAccess`
   - `IAMFullAccess`
   - `AmazonVPCFullAccess`

   *(For lab purposes only — use least privilege in production)*

5. Download:
   - **Access Key**
   - **Secret Key**

⚠️ **Save these securely** — you won't see the secret key again once you leave the page.

---

## Step 2: Install AWS CLI

### Ubuntu / Linux
```bash
sudo apt update && sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Verify:
```bash
aws --version
```

---

## Step 3: Configure AWS Credentials Locally

```bash
aws configure
```

Enter when prompted:
```
AWS Access Key ID:     <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name:   eu-north-1
Default output format: json
```

This creates:
```bash
~/.aws/credentials
~/.aws/config
```

Terraform will automatically read credentials from here.

---

## Step 4: Install Terraform

### Linux
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

Verify:
```bash
terraform version
```

**Expected:** `Terraform v1.6.0` or higher.

---

## Step 5: Verify VPC and Subnets

This setup requires an existing VPC with private subnets. Make sure you have:

- An **existing VPC** in `eu-north-1`
- At least **2 private subnets** in different availability zones

### In AWS Console:

1. Go to **VPC → Your VPCs**
2. Note your **VPC ID** (e.g., `vpc-038e06420977eb6db`)
3. Go to **VPC → Subnets**
4. Filter by your VPC and select the private subnets
5. Copy their **Subnet IDs** (e.g., `subnet-0669b3093e9b9585f`, `subnet-08b4f56f08a1eddc0`)

---

## Step 6: Configure Terraform Variables

Navigate to the dev environment directory:

```bash
cd infra/terraform/environments/dev
```

Create your `terraform.tfvars` from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and fill in your actual values:

```hcl
# ── Networking ────────────────────────────────────────────────
vpc_id = "vpc-xxxxxxxxxxxxxxxxx"

private_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy"
]

# ── RDS Credentials ───────────────────────────────────────────
db_username = "todoapp"
db_password = "changeme123"   # use a strong password
```

⚠️ **Important:** Never commit `terraform.tfvars` to git. Ensure your `.gitignore` contains:
```
*.tfvars
!*.tfvars.example
```

---

## Step 7: Create S3 Bucket for Remote State

```bash
aws s3api create-bucket \
  --bucket todo-list-terra-bucket \
  --region eu-north-1 \
  --create-bucket-configuration LocationConstraint=eu-north-1

aws s3api put-bucket-versioning \
  --bucket todo-list-terra-bucket \
  --versioning-configuration Status=Enabled
```

Also check the S3 bucket name in `infra/terraform/environments/dev/backend.tf` matches the bucket name above.

---

## Step 8: Initialize Terraform

```bash
terraform init
```

This downloads:
- AWS provider (`hashicorp/aws ~> 5.0`)
- TLS provider (for OIDC certificate)
- All module dependencies
- Connects to the S3 backend for remote state

**Expected output:**
```
Terraform has been successfully initialized!
```

---

## Step 9: Format and Validate

```bash
terraform fmt -recursive
terraform validate
```

**Expected:**
```
Success! The configuration is valid.
```

---

## Step 10: See What Terraform Will Do (Safe Step)

```bash
terraform plan
```

**It should show resources to be created across 4 modules:**

EKS module:
- `aws_eks_cluster`
- `aws_eks_node_group` — `t3.medium`, desired: 2, min: 1, max: 3
- `aws_iam_role` (cluster + node)
- `aws_security_group` (cluster + node)
- `aws_iam_openid_connect_provider`
- `aws_launch_template`

RDS module:
- `aws_db_instance` — PostgreSQL 16
- `aws_db_subnet_group`
- `aws_security_group` — port 5432 from EKS nodes only

IAM module:
- `aws_iam_role` — Load Balancer Controller
- `aws_iam_role` — GitHub Actions
- `aws_iam_policy` — LBC permissions
- `aws_iam_policy` — GitHub Actions permissions
- `aws_iam_openid_connect_provider` — GitHub Actions OIDC

ECR module:
- `aws_ecr_repository` — frontend
- `aws_ecr_repository` — backend

No actual changes are made at this step. Review the plan carefully before applying.

---

## Step 11: Apply to Create All Resources

```bash
terraform apply
```

Type **yes** when prompted to confirm.

### You should see (if there are no errors):
***Apply complete! Resources: X added, 0 changed, 0 destroyed.***

**Outputs:**
```bash
aws_region                             = "eu-north-1"
project_name                           = "todo-list-devops"
environment                            = "dev"
eks_cluster_name                       = "todo-list-devops-dev-eks-cluster"
eks_cluster_endpoint                   = "https://xxxxxxxxxxxxx.eks.eu-north-1.amazonaws.com"
eks_cluster_certificate_authority_data = "LS0tLS1CRUdJTi..."
eks_oidc_provider_arn                  = "arn:aws:iam::123456789:oidc-provider/..."
eks_cluster_security_group_id          = "sg-xxxxxxxxx"
rds_endpoint                           = "todo-list-devops-dev-rds.xxxxxxxxx.eu-north-1.rds.amazonaws.com"
rds_port                               = 5432
database_name                          = "tododb"
lbc_role_arn                           = "arn:aws:iam::123456789:role/todo-list-devops-dev-lbc-role"
github_actions_role_arn                = "arn:aws:iam::123456789:role/todo-list-devops-dev-github-actions-role"
frontend_repository_url                = "123456789.dkr.ecr.eu-north-1.amazonaws.com/todo-list-devops-dev-frontend"
backend_repository_url                 = "123456789.dkr.ecr.eu-north-1.amazonaws.com/todo-list-devops-dev-backend"
```

⏳ **Note:** EKS cluster creation takes approximately 10-15 minutes. RDS takes an additional 5-10 minutes. Please wait for the process to complete.

---

## Step 12: Verify in AWS Console

### EKS
1. Go to **EKS → Clusters**
2. Look for:
   - Name: `todo-list-devops-dev-eks-cluster`
   - Region: `eu-north-1`
   - Status: **ACTIVE**
3. Go to **EC2 → Instances** to verify worker nodes
   - You should see **2 instances** running (`desired_size = 2`)

### RDS
1. Go to **RDS → Databases**
2. Look for:
   - Identifier: `todo-list-devops-dev-rds`
   - Engine: **PostgreSQL 16**
   - Status: **Available**
   - Publicly accessible: **No**

### IAM
1. Go to **IAM → Roles**
2. Look for:
   - `todo-list-devops-dev-lbc-role`
   - `todo-list-devops-dev-github-actions-role`
3. Verify each trust policy references the correct OIDC provider

### ECR
1. Go to **ECR → Repositories**
2. Look for:
   - `todo-list-devops-dev-frontend`
   - `todo-list-devops-dev-backend`
3. Verify image scanning is enabled on both

---

## Step 13: Configure GitHub Actions Secrets

Go to your repo → **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|---|---|
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID |
| `AWS_REGION` | `eu-north-1` |
| `AWS_ROLE_ARN` | Value of `github_actions_role_arn` output from Step 11 |

⚠️ **Never** add your AWS Access Key or Secret Key as GitHub secrets — the OIDC role handles authentication securely without static credentials.

---

## Step 14: Configure kubectl

To interact with your EKS cluster:

```bash
aws eks update-kubeconfig \
  --name todo-list-devops-dev-eks-cluster \
  --region eu-north-1
```

Verify connection:
```bash
kubectl get nodes
```

**Expected:** 2 nodes in `Ready` status.

---

## Step 15: Destroy (IMPORTANT)

When you are done, clean up all resources to avoid unexpected AWS charges:

```bash
terraform destroy
```

Type **yes** when prompted to confirm.

⏳ **Note:** Destruction takes approximately 15-20 minutes (EKS + RDS both take time to tear down).

### Resources that will be destroyed:
- EKS cluster, node group, and EC2 instances
- RDS PostgreSQL instance and subnet group
- All IAM roles and policies
- All security groups
- OIDC providers
- ECR repositories

---

## Step 16: Prod Checklist

Before promoting to `environments/prod`, update these values:

- [ ] `multi_az = true` in RDS module
- [ ] `skip_final_snapshot = false` in RDS module
- [ ] `deletion_protection = true` in RDS module
- [ ] Use AWS Secrets Manager for credentials instead of `terraform.tfvars`
- [ ] Restrict `public_access_cidrs` on EKS cluster
- [ ] Enable EKS control plane logging
- [ ] Use larger instance types (`db.t3.small` or above for RDS, `t3.large` for nodes)
- [ ] Scope GitHub Actions IAM role to `main` branch only

CHEERS!