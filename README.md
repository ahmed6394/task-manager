# Todo List (Angular)

Full-stack Todo app (Angular + FastAPI + Postgres) with Docker, Helm on Kubernetes, and infrastructure provisioned via Terraform (EKS + RDS + ECR + IAM).

## Quick start

```bash
cd frontend
npm install
npm start
```

Local URL: `http://localhost:4200`

## Architecture

```text
Browser -> Angular SPA -> Nginx -> Service (frontend) -> Pods
                          /api  -> Service (backend)  -> Pods -> Postgres
```

- Frontend: Angular app in `src/app/` (`todo/` component + `Todo.model.ts`).
- Backend: FastAPI service with `/api` routes.
- Orchestration: Helm chart in `helm/todo-app` (Deployments, Services, Secrets, Ingress).
- Infrastructure: Terraform modules in `infra/terraform/` (EKS, RDS, ECR, IAM).

---

## Run with Docker

```bash
docker compose up --build todo-dev
docker compose --profile prod up --build todo-prod
docker compose down
```

Production URL (compose): `http://localhost:8080`

## Build and push image

```bash
docker build -t ahmed63/todo-list:v1 --target prod .
docker push ahmed63/todo-list:v1
```

---

## Infrastructure as Code (Terraform)

Provisions the full AWS infrastructure from scratch:

| Module | What it creates |
|---|---|
| `modules/eks` | EKS cluster + node group (`t3.medium` x2), security groups, OIDC provider |
| `modules/rds` | PostgreSQL 16 RDS instance, subnet group, security group (port 5432 from EKS only) |
| `modules/ecr` | ECR repositories for frontend and backend images |
| `modules/iam` | IAM roles for Load Balancer Controller and GitHub Actions (OIDC, no static keys) |

### Prerequisites

- AWS account with an IAM user (`AmazonEKSFullAccess`, `AmazonEC2FullAccess`, `AmazonRDSFullAccess`, `AmazonS3FullAccess`, `IAMFullAccess`, `AmazonVPCFullAccess`)
- An existing VPC with at least 2 private subnets in `eu-north-1`
- AWS CLI, Terraform, and kubectl installed locally

### 1. Configure AWS CLI

```bash
aws configure
# Enter: Access Key, Secret Key, region (eu-north-1), output format (json)
```

### 2. Create S3 bucket for remote state

```bash
aws s3api create-bucket \
  --bucket todo-list-terra-bucket \
  --region eu-north-1 \
  --create-bucket-configuration LocationConstraint=eu-north-1

aws s3api put-bucket-versioning \
  --bucket todo-list-terra-bucket \
  --versioning-configuration Status=Enabled
```

### 3. Configure variables

```bash
cd infra/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
private_subnet_ids = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy"]
db_username        = "todoapp"
db_password        = "your-strong-password"
```

> ⚠️ Never commit `terraform.tfvars` — it is git-ignored. Only `terraform.tfvars.example` is committed.

### 4. Deploy

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply   # type 'yes' to confirm
```

> ⏳ EKS takes ~10–15 min, RDS takes ~5–10 min.

### 5. Connect kubectl to EKS

```bash
aws eks update-kubeconfig \
  --name todo-list-devops-dev-eks-cluster \
  --region eu-north-1

kubectl get nodes   # should show 2 nodes Ready
```

### 6. Destroy when done

```bash
terraform destroy   # type 'yes' to confirm
```

> ⚠️ Always destroy when not in use to avoid AWS charges. Takes ~15–20 min.

---

## CI/CD (GitHub Actions)

Workflow file: `.github/workflows/main.yaml`

The pipeline runs on push to `main` (and can also be triggered manually).

### What the pipeline does

1. Builds the Docker image using the `prod` stage.
2. Pushes tags `v1` and `latest` to Docker Hub.
3. SSHes into an EC2 instance.
4. Pulls `ahmed63/todo-list:v1` on EC2.
5. Replaces the running `todo-list` container on port `80`.

### Required GitHub repository secrets

| Secret | Description |
|---|---|
| `DOCKER_USERNAME` | Docker Hub username (e.g. `ahmed63`) |
| `DOCKER_PASSWORD` | Docker Hub password or access token |
| `AWS_HOST` | EC2 public IP or DNS |
| `AWS_USER` | SSH user (e.g. `ubuntu`) |
| `AWS_KEY` | Full private key content (`.pem`) |
| `AWS_ACCOUNT_ID` | 12-digit AWS account ID (for ECR/EKS pipelines) |
| `AWS_REGION` | `eu-north-1` |
| `AWS_ROLE_ARN` | Value of `github_actions_role_arn` from `terraform apply` output |

> ⚠️ Never add AWS Access Key / Secret Key as GitHub secrets — the OIDC IAM role handles authentication securely.

---

## Deploy to Kubernetes (Helm)

### Prerequisites on the server

```bash
# Install k3s (single-node Kubernetes)
curl -sfL https://get.k3s.io | sh -
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Create private values file

```bash
cat > helm/todo-app/values-dev.private.yaml <<EOF
backend:
  secrets:
    databaseUrl: "postgresql://todouser:todopass@postgres.todo.svc.cluster.local:5432/tododb"
EOF
```

### Deploy

```bash
helm lint helm/todo-app
helm template todo-app helm/todo-app

helm upgrade --install todo-app helm/todo-app \
  --namespace todo --create-namespace \
  -f helm/todo-app/values.yaml \
  -f helm/todo-app/values-dev.private.yaml

kubectl get po -n todo
kubectl get deploy,svc -n todo
```

Access the app at: `http://<server-public-ip>:30080`

### Helm operations

```bash
helm list
helm history todo-app
helm rollback todo-app <revision-number>
```

### Helm values

- Base values: `helm/todo-app/values.yaml`
- Dev overrides: `helm/todo-app/values-dev.private.yaml` (secrets — not committed to git)

## Monitoring & Observability

The platform includes a full observability stack using **Prometheus**, **Node Exporter**, **Blackbox Exporter**, and **Grafana**.

### Monitoring Architecture

```text
                    ┌──────────────┐
                    │   Grafana    │
                    │ Dashboards   │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ Prometheus   │
                    │ Metrics DB   │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
 Node Exporter      Blackbox Exporter     Application
 Host Metrics       HTTP/SSL Probes       Metrics
```

### Infrastructure Monitoring

Node Exporter collects system-level metrics from Kubernetes worker nodes:

* CPU utilization
* Memory consumption
* Disk usage
* Network throughput
* File system statistics
* Load averages

![Node Exporter Dashboard](./monitoring-observability/images/node-exporter-cpu-mem-traffic-dashboard.png)

### Endpoint & Uptime Monitoring

Blackbox Exporter continuously probes application endpoints and external dependencies.

Monitored metrics include:

* HTTP status codes
* Response time
* DNS lookup latency
* SSL certificate validity
* Endpoint availability

![Blackbox Exporter Dashboard](./monitoring-observability/images/blackbox-dashboards-fullpage.png)

### Prometheus Target Health

Prometheus scrapes all exporters and services at regular intervals.

The target health page verifies:

* Node Exporter availability
* Blackbox Exporter availability
* Prometheus scrape success
* Endpoint status

![Prometheus Targets](./monitoring-observability/images/prometheus.png)

### Operational Benefits

✅ Real-time infrastructure visibility

✅ Early detection of service degradation

✅ Endpoint uptime monitoring

✅ SSL certificate expiration tracking

✅ Performance baseline establishment

✅ Faster troubleshooting and incident response
