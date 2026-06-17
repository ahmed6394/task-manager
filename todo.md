# TODO.md — Version 2: Professional AWS DevOps Project

## Project Goal

Build a production-like DevOps portfolio project using:

- Angular frontend
- FastAPI backend
- PostgreSQL database on AWS RDS
- Docker
- AWS ECR
- AWS EKS
- Terraform
- Ansible
- GitHub Actions CI/CD
- Helm
- AWS Load Balancer Controller
- Prometheus
- Grafana
- Optional Argo CD / GitOps

Final project story:

> This project demonstrates a full DevOps workflow: application development, containerization, infrastructure as code, Kubernetes orchestration, CI/CD automation, monitoring, and cloud deployment on AWS.

---

# Phase 0 — Planning and Repository Preparation

## 0.1 Define the final architecture

- [x] Frontend runs as an Angular container.
- [x] Backend runs as a FastAPI container.
- [x] PostgreSQL runs on AWS RDS, not inside Kubernetes for production.
- [x] Images are stored in AWS ECR.
- [x] Application runs on AWS EKS.
- [x] External traffic enters through AWS Load Balancer Controller.
- [x] Terraform provisions AWS infrastructure.
- [x] Ansible handles admin/bootstrap/configuration automation.
- [x] GitHub Actions handles CI/CD.
- [x] Prometheus and Grafana provide monitoring and dashboards.
- [x] Optional: Argo CD handles GitOps deployment.

## 0.2 Create target repository structure

- [x] Restructure the repository like this:

```text
todo-list/
  frontend/
  backend/
  docker-compose.yml

  helm/
    todo-app/

  infra/
    terraform/
      environments/
        dev/
        prod/
      modules/
        vpc/
        eks/
        rds/
        ecr/
        iam/
    ansible/
      inventory/
      playbooks/
      roles/

  monitoring/
    prometheus/
    grafana/
      dashboards/

  .github/
    workflows/

  docs/
    architecture.md
    deployment.md
    monitoring.md
    troubleshooting.md

  README.md
  TODO.md
```

## 0.3 Define naming conventions

- [x] Choose AWS region, for example `eu-central-1`.
- [x] Choose project name, for example `todo-devops`.
- [x] Choose environments:
  - [x] `dev`
  - [x] `prod`, optional for portfolio
- [x] Choose EKS cluster names:
  - [x] `todo-devops-dev`
  - [x] `todo-devops-prod`
- [x] Choose ECR repository names:
  - [x] `todo-frontend`
  - [x] `todo-backend`
- [x] Choose Kubernetes namespace:
  - [x] `todo`

## 0.4 Create project branches

- [x] Create `main` branch.
- [x] Create `dev` branch.
- [x] Create feature branches using this style:
  - [x] `feature/backend-fastapi`
  - [x] `feature/docker-compose`
  - [x] `feature/terraform-eks`
  - [x] `feature/github-actions`
  - [x] `feature/monitoring`

## Deliverable

- [x] Clean repository structure.
- [x] Clear naming convention.
- [x] Project roadmap committed as `TODO.md`.

---

# Phase 1 — Application Foundation

## 1.1 Prepare frontend

- [x] Move current Angular code into `frontend/` if not already done.
- [x] Confirm the app runs locally:

```bash
cd frontend
npm install
npm start
```

- [x] Add environment configuration for API URL.
- [x] Create frontend production build command.
- [x] Add a simple frontend health route or static landing page check.
- [x] Update frontend to call backend API through `/api`.

## 1.2 Create FastAPI backend

- [x] Create `backend/` directory.
- [x] Create FastAPI project structure:

```text
backend/
  app/
    main.py
    database.py
    models.py
    schemas.py
    config.py
    routers/
      todos.py
  tests/
  requirements.txt
  Dockerfile
```

- [x] Create `/health` endpoint.
- [x] Create `/api/todos` endpoints:
  - [x] `GET /api/todos`
  - [x] `POST /api/todos`
  - [x] `GET /api/todos/{id}`
  - [x] `PUT /api/todos/{id}`
  - [x] `DELETE /api/todos/{id}`
- [x] Add database connection using environment variables.
- [x] Add SQLAlchemy or SQLModel.
- [x] Add Alembic for migrations.
- [x] Add basic tests with `pytest`.

## 1.3 Add PostgreSQL locally

- [x] Add PostgreSQL service to `docker-compose.yml`.
- [x] Define database environment variables:
  - [x] `POSTGRES_DB`
  - [x] `POSTGRES_USER`
  - [x] `POSTGRES_PASSWORD`
  - [x] `DATABASE_URL`
- [x] Confirm backend can connect to PostgreSQL.
- [x] Run initial migration.
- [x] Test CRUD operations.

## 1.4 Add local Docker Compose

- [x] Create root-level `docker-compose.yml`.
- [x] Add services:
  - [x] `frontend`
  - [x] `backend`
  - [x] `postgres`
- [x] Confirm this command works:

```bash
docker compose up --build
```

- [x] Confirm frontend can call backend.
- [x] Confirm backend can read/write PostgreSQL data.

## Deliverable

- [x] Full-stack app works locally.
- [x] Angular frontend talks to FastAPI backend.
- [x] FastAPI backend talks to PostgreSQL.
- [x] Docker Compose starts the whole app.

---

# Phase 2 — Dockerization

## 2.1 Frontend Dockerfile

- [x] Create `frontend/Dockerfile`.
- [x] Use multi-stage build:
  - [x] Node stage builds Angular app.
  - [x] Nginx stage serves static files.
- [x] Add `frontend/nginx.conf`.
- [x] Configure Nginx to route `/api` requests to backend if needed.
- [x] Confirm build works:

```bash
docker build -t todo-frontend:local ./frontend
```

## 2.2 Backend Dockerfile

- [x] Create `backend/Dockerfile`.
- [x] Use lightweight Python image.
- [x] Install dependencies from `requirements.txt`.
- [x] Run app with `uvicorn`.
- [x] Expose port `8000`.
- [x] Confirm build works:

```bash
docker build -t todo-backend:local ./backend
```

## 2.3 Image tagging strategy

- [x] Use Git commit SHA as image tag.
- [x] Use semantic tags for releases.
- [x] Avoid relying on `latest` for deployment.
- [x] Final tag examples:
  - [x] `todo-frontend:<git-sha>`
  - [x] `todo-backend:<git-sha>`

## Deliverable

- [x] Frontend image builds successfully.
- [x] Backend image builds successfully.
- [x] Docker Compose can use local images.
- [x] Image tagging strategy documented.

---

# Phase 3 — Kubernetes and Helm

## 3.1 Create Helm chart

- [x] Create chart:

```bash
helm create helm/todo-app
```

## 3.2 Create initial Kubernetes manifests

- [x] Create Kubernetes namespace:

```text
helm/todo-app/templates/namespace.yaml
```

- [x] Create frontend Kubernetes resources:
  - [x] Deployment
  - [x] Service

- [x] Create Postgres Kubernetes resources:
  - [x] Deployment
  - [x] Service
  - [x] Secret reference
  
- [x] Create backend Kubernetes resources:
  - [x] Deployment
  - [x] Service
  - [x] Secret reference
  - [x] Resource requests and limits

- [x] Clean unnecessary default templates.
- [x] Add templates:
  - [x] `frontend-deployment.yaml`
  - [x] `frontend-service.yaml`
  - [x] `backend-deployment.yaml`
  - [x] `backend-service.yaml`
  - [x] `postgres-deployment.yaml`
  - [x] `postgres-service.yaml`
  - [x] `ingress.yaml`
  - [x] `secret.yaml`
  - [x] `hpa.yaml`

## 3.3 Configure Helm values

- [x] Add frontend values:
- [x] Add backend values:
- [x] Add ingress values:
- [x] Add resource limits.
- [x] Add autoscaling values.

## 3.4 Test and install Helm locally

```bash
helm lint helm/todo-app
helm template todo-app helm/todo-app
helm install todo-app helm/todo-app --namespace todo --create-namespace \
  -f helm/todo-app/values.yaml \
  -f helm/todo-app/values-dev.private.yaml
```

- [x] Confirm pods, delpoys, svc are running:

```bash
kubectl get pods,deploy,svc -n todo
```

- [x] Update the release:

```bash
helm upgrade --install todo-app helm/todo-app --namespace todo --create-namespace \
  -f helm/todo-app/values.yaml \
  -f helm/todo-app/values-dev.private.yaml
```

- [x] Rollback the release:

```bash
helm list
helm history todo-ap
helm rollback todo-app <revision-number>
```

## Deliverable

- [x] Helm chart deploys app successfully.
- [x] Helm chart supports configurable image tags.
- [x] App can run on local Kubernetes.

---

# Phase 4 — Terraform Infrastructure

## 4.1 Create Terraform base structure

- [x] Create:

```text
infra/terraform/
  environments/
    dev/
      main.tf
      variables.tf
      outputs.tf
      backend.tf
      terraform.tfvars.example
    prod/
      main.tf
      variables.tf
      outputs.tf
      backend.tf
      terraform.tfvars.example
  modules/
    vpc/
    eks/
    rds/
    ecr/
    iam/
```

## 4.2 Configure Terraform backend

- [x] Create S3 bucket for Terraform state.
- [x] Create DynamoDB table for state locking, optional but recommended.
- [x] Add backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "todo-devops/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## 4.3 Create VPC module

- [x] Create VPC.
- [x] Create public subnets.
- [x] Create private subnets.
- [x] Create internet gateway.
- [x] Create NAT gateway, optional for cost control.
- [x] Add route tables.
- [x] Add tags required by EKS and load balancers.
- [x] Output:
  - [x] `vpc_id`
  - [x] `public_subnets`
  - [x] `private_subnets`

## 4.4 Create ECR module

- [x] Create ECR repository for frontend.
- [x] Create ECR repository for backend.
- [x] Enable image scanning if desired.
- [x] Add lifecycle policy to remove old images.
- [x] Output:
  - [x] `frontend_repository_url`
  - [x] `backend_repository_url`

## 4.5 Create EKS module

- [x] Create EKS cluster.
- [x] Create managed node group.
- [x] Use private subnets for worker nodes.
- [x] Configure IAM roles.
- [x] Configure cluster security group.
- [x] Enable OIDC provider for IAM roles for service accounts.
- [x] Output:
  - [x] `cluster_name`
  - [x] `cluster_endpoint`
  - [x] `cluster_certificate_authority_data`
  - [x] `oidc_provider_arn`

## 4.6 Create RDS module

- [x] Create DB subnet group.
- [x] Create PostgreSQL RDS instance.
- [x] Place RDS in private subnets.
- [x] Create RDS security group.
- [x] Allow PostgreSQL access only from EKS worker node security group.
- [x] Store username and password securely.
- [x] Output:
  - [x] `rds_endpoint`
  - [x] `rds_port`
  - [x] `database_name`

## 4.7 Add IAM/OIDC support

- [x] Enable EKS OIDC provider.
- [x] Add IAM role for AWS Load Balancer Controller.

## 4.8 Validate Terraform

- [x] Run:

```bash
cd infra/terraform/environments/dev
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

## 4.9 Apply Terraform

- [x] Apply infrastructure:

```bash
terraform apply
```

- [x] Save outputs.
- [x] Update kubeconfig:

```bash
aws eks update-kubeconfig --region eu-central-1 --name todo-devops-dev
```

- [x] Validate cluster:

```bash
kubectl get nodes
```

## Deliverable

- [x] AWS VPC created.
- [x] ECR repositories created.
- [x] EKS cluster created.
- [x] RDS PostgreSQL created.
- [x] Terraform outputs documented.
- [x] Local kubectl can access EKS.

---


# Phase 5 — ECR + GitHub Actions CI/CD

## 5.1 Create ECR Terraform module

- [ ] Create `infra/terraform/modules/ecr/main.tf`:
  - [ ] Create ECR repository for frontend: `todo-frontend`
  - [ ] Create ECR repository for backend: `todo-backend`
  - [ ] Enable image tag immutability
  - [ ] Enable image scanning on push
- [ ] Create `infra/terraform/modules/ecr/variables.tf`
- [ ] Create `infra/terraform/modules/ecr/outputs.tf`:
  - [ ] `frontend_repository_url`
  - [ ] `backend_repository_url`
- [ ] Wire ECR module into `environments/dev/main.tf`
- [ ] Add ECR outputs to `environments/dev/outputs.tf`
- [ ] Run:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## 5.2 Configure GitHub Actions OIDC with AWS

- [ ] Add IAM role for GitHub Actions in `modules/iam/main.tf`:
  - [ ] Trust policy scoped to your GitHub repo
  - [ ] Attach ECR push permissions
  - [ ] Attach EKS deploy permissions
- [ ] Add output `github_actions_role_arn`
- [ ] Add GitHub Actions secrets in repo settings:
  - [ ] `AWS_ACCOUNT_ID`
  - [ ] `AWS_REGION`

## 5.3 Create CI workflow — Build and push images

- [ ] Create `.github/workflows/ci.yml`
- [ ] Trigger on: push to `dev` branch
- [ ] Jobs:
  - [ ] `test-backend` — run `pytest`
  - [ ] `build-and-push` — build and push images to ECR
    - [ ] Tag images with Git commit SHA
    - [ ] Tag images with `latest`

## 5.4 Create CD workflow — Deploy to EKS

- [ ] Create `.github/workflows/cd.yml`
- [ ] Trigger on: successful CI workflow
- [ ] Jobs:
  - [ ] Configure `kubectl` with EKS cluster
  - [ ] Run `helm upgrade --install` with new image tag

## Deliverable

- [ ] ECR repositories exist in AWS
- [ ] Images are pushed to ECR on every push to `dev`
- [ ] App is deployed to EKS automatically after successful build

---

# Phase 6 — AWS Load Balancer Controller

## 6.1 Install AWS Load Balancer Controller

- [ ] Add `eks.amazonaws.com/role-arn` annotation to LBC service account using `lbc_role_arn` output from Terraform
- [ ] Install LBC via Helm:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=todo-list-devops-dev-eks-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<lbc_role_arn>
```

- [ ] Verify LBC is running:

```bash
kubectl get pods -n kube-system | grep aws-load-balancer
```

## 6.2 Update Helm ingress for ALB

- [ ] Update `helm/todo-app/templates/ingress.yaml` with ALB annotations:
  - [ ] `kubernetes.io/ingress.class: alb`
  - [ ] `alb.ingress.kubernetes.io/scheme: internet-facing`
  - [ ] `alb.ingress.kubernetes.io/target-type: ip`
- [ ] Update `helm/todo-app/values.yaml` ingress section
- [ ] Redeploy Helm chart and verify ALB is created in AWS console

## Deliverable

- [ ] LBC is running in `kube-system` namespace
- [ ] ALB is created automatically when ingress is deployed
- [ ] App is accessible via ALB DNS name

---

# Phase 7 — Prometheus + Grafana

## 7.1 Install kube-prometheus-stack

- [ ] Add Helm repo:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

- [ ] Install stack:

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

- [ ] Verify pods are running:

```bash
kubectl get pods -n monitoring
```

## 7.2 Expose FastAPI metrics

- [ ] Add `prometheus-fastapi-instrumentator` to `backend/requirements.txt`
- [ ] Add metrics setup to `backend/app/main.py`:
  - [ ] Expose `/metrics` endpoint
- [ ] Rebuild and push backend image

## 7.3 Create ServiceMonitor

- [ ] Create `monitoring/prometheus/servicemonitor.yaml`:
  - [ ] Target backend service on `/metrics`
- [ ] Apply to cluster:

```bash
kubectl apply -f monitoring/prometheus/servicemonitor.yaml
```

- [ ] Verify target appears in Prometheus UI:

```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
```

## 7.4 Set up Grafana dashboard

- [ ] Access Grafana:

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

- [ ] Default credentials: `admin / prom-operator`
- [ ] Import dashboard:
  - [ ] Use dashboard ID `15760` (FastAPI metrics) from Grafana.com
- [ ] Save dashboard to `monitoring/grafana/dashboards/fastapi-dashboard.json`

## Deliverable

- [ ] Prometheus is scraping FastAPI metrics
- [ ] Grafana dashboard shows pod health and request count
- [ ] Dashboard JSON saved to repo

---

# Phase 8 — ArgoCD

## 8.1 Install ArgoCD

- [ ] Install via Helm:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace
```

- [ ] Access ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

- [ ] Get initial admin password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

## 8.2 Create ArgoCD Application manifest

- [ ] Create `infra/argocd/todo-app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: todo-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<your-org>/todo-list
    targetRevision: dev
    path: helm/todo-app
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: todo
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

- [ ] Apply to cluster:

```bash
kubectl apply -f infra/argocd/todo-app.yaml
```

## 8.3 Update GitHub Actions for GitOps flow

- [ ] Update CD workflow to update image tag in `helm/todo-app/values.yaml` instead of running `helm upgrade`
- [ ] ArgoCD detects the change and syncs automatically

New flow:
```
push to dev
  → GitHub Actions builds image
  → GitHub Actions updates image tag in values.yaml
  → ArgoCD detects change
  → ArgoCD syncs app to EKS
```

## Deliverable

- [ ] ArgoCD is installed and accessible
- [ ] ArgoCD manages the todo app deployment
- [ ] Git is the source of truth for deployment
- [ ] ArgoCD auto-syncs on values.yaml change

---

# Phase 9 — Ansible

## 9.1 Create inventory

- [ ] Create `infra/ansible/inventory/hosts.ini`:

```ini
[local]
localhost ansible_connection=local
```

## 9.2 Create tool installation playbook

- [ ] Create `infra/ansible/playbooks/install-tools.yml`:
  - [ ] Install `kubectl`
  - [ ] Install `helm`
  - [ ] Install `awscli`
  - [ ] Install `terraform`

## 9.3 Create cluster validation playbook

- [ ] Create `infra/ansible/playbooks/validate-cluster.yml`:
  - [ ] Run `kubectl get nodes`
  - [ ] Run `kubectl get pods -n todo`
  - [ ] Run `kubectl get pods -n monitoring`
  - [ ] Print cluster health summary

## 9.4 Run and verify

```bash
ansible-playbook -i infra/ansible/inventory/hosts.ini \
  infra/ansible/playbooks/install-tools.yml

ansible-playbook -i infra/ansible/inventory/hosts.ini \
  infra/ansible/playbooks/validate-cluster.yml
```

## Deliverable

- [ ] Tool installation playbook works on a fresh machine
- [ ] Cluster validation playbook confirms healthy state
- [ ] Ansible usage documented in README

---

# Phase 10 — Documentation + Portfolio

## 10.1 Update README

- [ ] Add architecture diagram
- [ ] Add tech stack table
- [ ] Add local setup instructions
- [ ] Add Terraform deployment instructions
- [ ] Add CI/CD flow explanation
- [ ] Add monitoring access instructions
- [ ] Add cost warning
- [ ] Add cleanup instructions

## 10.2 Add architecture diagram

- [ ] Create `docs/architecture.md` with:
  - [ ] High-level architecture diagram
  - [ ] CI/CD flow diagram
  - [ ] AWS infrastructure diagram

## 10.3 Screenshots to capture

- [ ] App running in browser via ALB
- [ ] GitHub Actions successful CI/CD run
- [ ] AWS EKS cluster page
- [ ] AWS RDS instance
- [ ] `kubectl get pods -n todo`
- [ ] Prometheus targets page
- [ ] Grafana dashboard
- [ ] ArgoCD dashboard

## Deliverable

- [ ] README is portfolio-ready
- [ ] Architecture is documented
- [ ] Screenshots added to README

---

# Phase 11 — Cleanup

## 11.1 Cleanup commands

- [ ] Delete app:

```bash
helm uninstall todo-app -n todo
```

- [ ] Delete monitoring:

```bash
helm uninstall monitoring -n monitoring
```

- [ ] Delete ArgoCD:

```bash
helm uninstall argocd -n argocd
```

- [ ] Destroy infrastructure:

```bash
cd infra/terraform/environments/dev
terraform destroy
```

## 11.2 Confirm deleted in AWS Console

- [ ] EKS cluster
- [ ] EC2 nodes
- [ ] Load balancer
- [ ] RDS instance
- [ ] ECR repositories (optional)

---

# Recommended Build Order (Phase 5 Onwards)

1. Create ECR Terraform module and apply
2. Configure GitHub OIDC IAM role
3. Create CI workflow (build + push to ECR)
4. Create CD workflow (deploy to EKS via Helm)
5. Install AWS Load Balancer Controller
6. Update Helm ingress for ALB
7. Install Prometheus + Grafana
8. Expose FastAPI metrics + ServiceMonitor
9. Set up Grafana dashboard
10. Install ArgoCD
11. Create ArgoCD Application manifest
12. Update GitHub Actions for GitOps flow
13. Create Ansible playbooks
14. Write documentation and capture screenshots
15. Record cleanup instructions
# Final Completion Checklist

## 1. Application
- [ ] Angular frontend complete.
- [ ] FastAPI backend complete.
- [ ] PostgreSQL integration complete.
- [ ] CRUD operations complete.
- [ ] Health endpoint complete.
- [ ] Metrics endpoint complete.

## 2. Docker
- [ ] Frontend Dockerfile complete.
- [ ] Backend Dockerfile complete.
- [ ] Docker Compose complete.
- [ ] Images build successfully.

## 3. Kubernetes and Helm
- [ ] Helm chart complete.
- [ ] Frontend Deployment complete.
- [ ] Backend Deployment complete.
- [ ] Services complete.
- [ ] Ingress complete.
- [ ] Probes and resource limits complete.
- [ ] HPA complete.

## 4. AWS and Terraform
- [ ] Remote state complete.
- [ ] VPC complete.
- [ ] EKS complete.
- [ ] RDS complete.
- [ ] ECR complete.
- [ ] IAM/OIDC complete.
- [ ] Terraform plan/apply works.

## 5. CI/CD
- [ ] Backend CI complete.
- [ ] Frontend CI complete.
- [ ] Docker build workflow complete.
- [ ] EKS deploy workflow complete.
- [ ] Terraform plan workflow complete.
- [ ] Terraform apply workflow complete.
- [ ] Rollback documented.

## 6. ArgoCD
- [ ] ArgoCD installed.
- [ ] Application manifest complete.
- [ ] GitOps flow configured.
- [ ] Auto-sync verified.

## 7. Monitoring
- [ ] Prometheus installed.
- [ ] Grafana installed.
- [ ] FastAPI metrics exposed.
- [ ] ServiceMonitor complete.
- [ ] Dashboard complete.
- [ ] Alerts complete.

## 8. Security
- [ ] Secrets are not committed.
- [ ] GitHub OIDC configured.
- [ ] RDS is private.
- [ ] Image scanning complete.
- [ ] Resource limits complete.

## 9. Ansible
- [ ] Tool installation playbook complete.
- [ ] Cluster validation playbook complete.
- [ ] Ansible usage documented.

## 10. Documentation
- [ ] README complete.
- [ ] Architecture diagram complete.
- [ ] Deployment doc complete.
- [ ] Monitoring doc complete.
- [ ] Troubleshooting doc complete.
- [ ] Screenshots added.
- [ ] Demo video prepared.
---

# Recommended Build Order Summary

Use this exact order:

1. Restructure repository.
2. Add FastAPI backend.
3. Add PostgreSQL locally.
4. Add Docker Compose.
5. Dockerize frontend and backend.
6. Create Helm chart.
7. Test Helm locally.
8. Create Terraform VPC.
9. Create Terraform ECR.
10. Create Terraform EKS.
11. Create Terraform RDS.
12. Configure kubectl access to EKS.
13. Install AWS Load Balancer Controller.
14. Deploy app to EKS manually with Helm.
15. Add GitHub Actions CI.
16. Add Docker image build and push to ECR.
17. Add GitHub Actions deploy to EKS.
18. Add Terraform plan/apply workflows.
19. Add Ansible automation.
20. Add Prometheus and Grafana.
21. Add FastAPI metrics and ServiceMonitor.
22. Add Grafana dashboard and alerts.
23. Add security improvements.
24. Add documentation and screenshots.
25. Optional: add Argo CD GitOps.
26. Record demo video.
27. Add cleanup instructions.

---

# Notes for Recruiters / Reviewers

This project demonstrates:

- Full-stack application development
- Docker-based containerization
- Kubernetes deployment
- AWS EKS orchestration
- AWS RDS managed database
- AWS ECR container registry
- Terraform infrastructure as code
- Ansible automation
- GitHub Actions CI/CD
- Helm-based deployment
- Prometheus monitoring
- Grafana visualization
- Cloud security basics
- Production-like documentation

