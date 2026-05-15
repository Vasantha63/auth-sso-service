# Auth/SSO Service — DevOps Pipeline

A production-ready Auth/SSO microservice with complete DevOps pipeline.

## 🚀 Tech Stack

| Tool | Purpose |
|------|---------|
| FastAPI | Auth REST API with JWT |
| Docker | Containerization |
| AWS ECR | Container Registry |
| Terraform | Infrastructure as Code |
| Kubernetes (K3s) | Container Orchestration |
| Prometheus | Metrics Collection |
| Grafana | Monitoring Dashboard |
| GitHub Actions | CI/CD Pipeline |

## 📁 Project Structure

auth-sso-service/
├── app/
│   ├── main.py          # FastAPI app with JWT auth
│   ├── Dockerfile       # Container definition
│   └── requirements.txt
├── terraform/
│   ├── main.tf          # AWS EC2, VPC, Security Groups
│   └── variables.tf
├── k8s/
│   ├── deployment.yaml  # Kubernetes deployment
│   └── service.yaml
├── monitoring/
│   ├── prometheus.yaml  # Metrics scraping config
│   └── grafana.yaml     # Grafana K8s deployment
├── docker-compose.yml   # Local monitoring stack
└── .github/workflows/
└── ci-cd.yaml       # GitHub Actions pipeline

## 🔧 API Endpoints

- `POST /token` — Login, returns JWT token
- `GET /health` — Health check
- `GET /metrics` — Prometheus metrics

## 🏃 Run Locally

```bash
docker-compose up -d
```

- Auth Service: http://localhost:8000/docs
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

## ☁️ AWS Infrastructure

- EC2 t2.micro (Mumbai — ap-south-1)
- VPC + Public Subnet + Internet Gateway
- Security Groups (port 8000, 22)
- ECR Repository for Docker images