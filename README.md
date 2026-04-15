# SafePipeline

<div align="center">

**End-to-end DevSecOps lab — Build. Scan. Deploy. Defend.**

[![CI Status](https://github.com/Annou91/SafePipeline/actions/workflows/pipeline.yml/badge.svg)](https://github.com/Annou91/SafePipeline/actions/workflows/pipeline.yml)
[![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![OWASP ZAP](https://img.shields.io/badge/DAST-OWASP%20ZAP-E02020?style=for-the-badge&logo=owasp&logoColor=white)](https://www.zaproxy.org/)
[![Wazuh](https://img.shields.io/badge/SIEM-Wazuh-005571?style=for-the-badge&logo=elastic&logoColor=white)](https://wazuh.com/)
[![Prometheus](https://img.shields.io/badge/Metrics-Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Dashboards-Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)

<br/>

> ⚠️ **Educational project** — Contains intentional vulnerabilities for security learning. **Do not deploy in production.**

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [CI/CD Pipeline](#️-cicd-pipeline)
- [Security Features](#-security-features)
- [Monitoring](#-monitoring)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Simulated Attacks](#-simulated-attacks)
- [Team](#-team)

---

## 🔍 Overview

**SafePipeline** is a fully integrated DevSecOps platform built to demonstrate how development, security, and operations work together in a modern cloud-native environment.

The project revolves around a deliberately vulnerable web application deployed through an automated CI/CD pipeline, with real-time security monitoring and active threat detection. Every commit triggers a full build → scan → deploy cycle, simulating the continuous security posture required in production-grade systems.

**Key goals:**
- Automate the full software lifecycle: build → test → scan → deploy
- Detect and respond to attacks in real time using industry-standard SIEM tools
- Practice both offensive (attack simulation) and defensive (detection, blocking) security techniques
- Demonstrate infrastructure-as-code and container orchestration skills

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                       DEVELOPER WORKSTATION                         │
│                        git push → GitHub                            │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      GITHUB ACTIONS (CI/CD)                         │
│   Build → Unit Tests → SAST → Docker Build → DAST (ZAP) → Deploy   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       KUBERNETES CLUSTER                            │
│                                                                     │
│  ┌──────────────────┐  ┌───────────────────┐  ┌──────────────────┐ │
│  │   Web App Pod    │  │ Prometheus+Grafana │  │  Wazuh+Fail2Ban  │ │
│  └──────────────────┘  └───────────────────┘  └──────────────────┘ │
│                                                                     │
│                          Ingress (NGINX)                            │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
                    External Traffic / Simulated Attacks
```

Infrastructure is provisioned via **Terraform**. All Kubernetes resources are defined as code in `/k8s`.

---

## 🛠 Tech Stack

| Category | Technology | Role |
|---|---|---|
| **Containerization** | Docker | Package and isolate application services |
| **Orchestration** | Kubernetes | Deploy, scale, and manage containers |
| **CI/CD** | GitHub Actions | Automate build, test, scan, deploy |
| **IaC** | Terraform | Provision and manage cloud infrastructure |
| **Monitoring** | Prometheus | Collect system and application metrics |
| **Visualization** | Grafana | Dashboards and alerting |
| **DAST** | OWASP ZAP | Dynamic application vulnerability scanning |
| **SIEM** | Wazuh | Log collection, analysis, intrusion detection |
| **Protection** | Fail2Ban | Automatic IP blocking on attack detection |

---

## ⚙️ CI/CD Pipeline

Every `git push` to `main` (or any PR targeting `main`) triggers the full pipeline:

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────┐   ┌──────────────┐
│ 1. Build  │ → │ 2. Tests  │ → │  3. SAST  │ → │  4. Docker   │ → │  5. DAST     │
│ + Lint    │   │ (pytest)  │   │ (Bandit)  │   │    Build     │   │ (OWASP ZAP)  │
└──────────┘   └──────────┘   └──────────┘   └──────────────┘   └──────────────┘
```

1. **Build & Lint** — Install dependencies, run `flake8` code quality checks
2. **Tests** — Run `pytest` unit tests
3. **SAST** — Static code analysis with Bandit (detects SQLi patterns, weak crypto, hardcoded secrets)
4. **Docker Build** — Build and tag the container image with the commit SHA
5. **DAST** — Launch the app in Docker, run OWASP ZAP full scan, upload HTML/JSON/MD reports as artifacts

> ZAP reports are available in the **Actions → Artifacts** tab after every run.

---

## 🔐 Security Features

### Intentional Vulnerabilities (for testing)

| Vulnerability | Type | Purpose |
|---|---|---|
| SQL Injection | Input validation flaw | Test DAST tools and detection rules |
| Cross-Site Scripting (XSS) | Output encoding flaw | Validate alerting mechanisms |
| Weak Authentication | Logic flaw | Simulate brute-force scenarios |

### Detection & Response Stack

**Wazuh (SIEM)**
- Collects and correlates logs from all containers and nodes
- Generates alerts on suspicious patterns (failed logins, injection attempts, port scans)
- Provides a centralized security dashboard

**Fail2Ban**
- Monitors authentication logs in real time
- Automatically bans IPs exceeding defined failure thresholds
- Configurable rules per attack type (SSH, HTTP, custom app logs)

**OWASP ZAP**
- Integrated as a DAST step directly in the CI/CD pipeline
- Scans every new deployment for known vulnerabilities
- Reports uploaded as pipeline artifacts for review

---

## 📊 Monitoring

Prometheus scrapes metrics from the application and cluster nodes. Grafana provides real-time dashboards covering:

- **System** — CPU usage, memory, disk I/O
- **Application** — Request rate, error rate (4xx/5xx), response time
- **Security** — Failed login attempts, blocked IPs, Wazuh alert count
- **Kubernetes** — Pod health, restart count, resource consumption

> Custom Grafana dashboards are stored as JSON in `/monitoring/dashboards/`.

---

## 📁 Project Structure

```
SafePipeline/
│
├── app/                         # Flask web application (the target)
│   ├── app.py                   # Routes + intentional vulnerabilities (SQLi, XSS)
│   ├── database.py              # SQLite initialization
│   ├── requirements.txt
│   ├── templates/               # HTML pages (login, dashboard)
│   └── Dockerfile
│
├── k8s/                         # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
├── infra/                       # Terraform (Infrastructure as Code)
│   ├── main.tf                  # K8s namespaces provisioning
│   ├── variables.tf
│   └── outputs.tf
│
├── monitoring/                  # Prometheus & Grafana stack
│   ├── docker-compose.yml
│   ├── prometheus.yml
│   └── dashboards/              # Pre-built Grafana dashboards (JSON)
│
├── security/                    # Security tooling
│   ├── wazuh/                   # SIEM + custom detection rules
│   ├── fail2ban/                # IP blocking jails and filters
│   ├── zap/                     # OWASP ZAP automation config
│   └── attacks/                 # Controlled attack scripts
│
├── .github/
│   └── workflows/
│       └── pipeline.yml         # 5-stage CI/CD pipeline
│
└── docs/
    ├── SafePipeline_Documentation_Complete.md  # Full educational guide (EN)
    └── ATTACK_RUNBOOK.md        # Step-by-step attack reproduction
```

---

## 🚀 Getting Started

### Prerequisites

| What you want to run | What you need |
|---|---|
| App only | Docker |
| App + Monitoring | Docker + Docker Compose |
| App + Monitoring + Wazuh | Docker + 8 GB RAM |
| Full K8s deployment | minikube + kubectl + Terraform ≥ 1.3 |

### Quick Start — Run Locally in 60 Seconds

The entire stack runs on your local machine. No cloud account required.

```bash
# 1. Clone the repository
git clone https://github.com/Annou91/SafePipeline.git
cd SafePipeline

# 2. Build and start the vulnerable app
docker build -t safepipeline-app ./app
docker run -d -p 5000:5000 --name safepipeline safepipeline-app

# 3. Open in your browser
# http://localhost:5000/login
# Test credentials: admin / admin123
```

### Full Stack (App + Monitoring)

```bash
# Start the app
docker run -d -p 5000:5000 --name safepipeline safepipeline-app

# Start Prometheus + Grafana
cd monitoring/
docker compose up -d

# Access points:
# App       → http://localhost:5000
# Prometheus → http://localhost:9090
# Grafana    → http://localhost:3000  (admin / admin)
```

### Full Stack with Security (+ Wazuh SIEM)

> Requires 8 GB RAM allocated to Docker

```bash
cd security/wazuh/
docker compose up -d
# Wazuh Dashboard → https://localhost  (admin / SecretPassword)
```

### Kubernetes Deployment (Minikube)

```bash
# 1. Start minikube
minikube start

# 2. Load the Docker image
minikube image load safepipeline-app:latest

# 3. Provision namespaces with Terraform
cd infra/
terraform init
terraform apply

# 4. Deploy to Kubernetes
kubectl apply -f k8s/
kubectl get pods -w

# 5. Get the app URL
minikube service safepipeline-service --url
```

### Run the Full Pipeline Locally (Without GitHub Actions)

```bash
# Lint
pip install flake8 && flake8 app/ --max-line-length=120

# SAST
pip install bandit && bandit -r app/ -ll

# Docker build
docker build -t safepipeline-app:local ./app

# DAST (ZAP) — requires the app to be running on port 5000
docker run --rm -v $(pwd):/zap/wrk/:rw --network=host \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py -t http://localhost:5000 -r report_html.html -I
```

---

## 💥 Simulated Attacks

All scripts are located in `/security/attacks/` and must be run against a **local or isolated environment only**.

| Attack | Tool | Detection |
|---|---|---|
| Brute force login | `hydra` / custom script | Wazuh alert + Fail2Ban ban |
| SQL Injection | `sqlmap` / manual | ZAP report + Wazuh log |
| Port scanning | `nmap` | Wazuh IDS alert |
| XSS payload | Manual / ZAP | ZAP scan finding |

> ⚠️ Never run attack simulations against systems you do not own.

---

## 👥 Team

| GitHub | Role | Responsibilities |
|--------|------|-----------------|
| [@Annou91](https://github.com/Annou91) | Developer | Flask app, Docker, CI/CD pipeline, Kubernetes, Terraform |
| [@tisssam](https://github.com/tisssam) | Security Engineer | Wazuh, Fail2Ban, OWASP ZAP, attack simulations, log analysis |

*Shared:* Prometheus/Grafana, architecture design, documentation, peer reviews.

---

## 📄 License

This project is intended for **educational purposes only**.  
All vulnerabilities are introduced intentionally in a controlled environment.

---

<div align="center">

**SafePipeline** — *Secure by design, vulnerable by intent.*

</div>
