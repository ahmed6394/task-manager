# Todo List (Angular)

Full-stack Todo app (Angular + FastAPI + Postgres) with Docker and Helm on Kubernetes.

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
						  /api -> Service (backend) -> Pods -> Postgres
```

- Frontend: Angular app in `src/app/` (`todo/` component + `Todo.model.ts`).
- Backend: FastAPI service with `/api` routes.
- Orchestration: Helm chart in `helm/todo-app` (Deployments, Services, Secrets, Ingress).


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

Add these in GitHub repository settings:

- `DOCKER_USERNAME` - Docker Hub username (example: `ahmed63`)
- `DOCKER_PASSWORD` - Docker Hub password or access token
- `AWS_HOST` - EC2 public IP or DNS where container is deployed
- `AWS_USER` - SSH user for that EC2 instance (example: `ubuntu`)
- `AWS_KEY` - Full private key content (`.pem`) for EC2 SSH access



## Deploy to Kubernetes (Helm)

```bash
helm lint helm/todo-app
helm template todo-app helm/todo-app
helm install todo-app helm/todo-app \
	--namespace todo --create-namespace \
	-f helm/todo-app/values.yaml \
	-f helm/todo-app/values-dev.private.yaml
kubectl get po -n todo
kubectl get deploy,svc -n todo
helm upgrade --install todo-app helm/todo-app \
	--namespace todo --create-namespace \
	-f helm/todo-app/values.yaml \
	-f helm/todo-app/values-dev.private.yaml
helm list
helm history todo-ap
helm rollback todo-app <revision-number>
```

### Helm values

- Base values: `helm/todo-app/values.yaml`
- Dev overrides: `helm/todo-app/values-dev.private.yaml` (secrets and env overrides)
