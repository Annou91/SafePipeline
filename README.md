<div align="center">

### **A complete DevSecOps platform — Build. Scan. Deploy. Defend.**

<br/>

[![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![OWASP ZAP](https://img.shields.io/badge/DAST-OWASP%20ZAP-E02020?style=for-the-badge&logo=owasp&logoColor=white)](https://www.zaproxy.org/)
[![Wazuh](https://img.shields.io/badge/SIEM-Wazuh-005571?style=for-the-badge&logo=elastic&logoColor=white)](https://wazuh.com/)
[![Prometheus](https://img.shields.io/badge/Metrics-Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Dashboards-Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)

<br/>

> ⚠️ **Educational project** — This application contains intentional vulnerabilities for security research and learning. **Do not deploy in production.**

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

Every `git push` to the main branch triggers the full pipeline:

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ 1. Build  │ → │ 2. Tests  │ → │ 3. Scan   │ → │ 4. Docker │ → │ 5. Deploy │
│           │   │ (pytest)  │   │ SAST+ZAP  │   │   Build   │   │  to K8s  │
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
```

1. **Build** — Install dependencies, compile assets
2. **Tests** — Unit and integration tests
3. **Security Scan** — SAST static analysis + OWASP ZAP DAST scan against a staging instance
4. **Docker Build** — Build and tag the container image
5. **Deploy** — Apply Kubernetes manifests with zero-downtime rollout

> ZAP scan reports are automatically uploaded as GitHub Actions artifacts on every run.

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
├── app/                    # Web application source code
│   ├── src/
│   ├── tests/
│   └── Dockerfile
│
├── k8s/                    # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
├── infra/                  # Terraform configuration
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── monitoring/             # Prometheus & Grafana setup
│   ├── prometheus.yml
│   └── dashboards/
│
├── security/               # Security tooling configs
│   ├── wazuh/
│   ├── fail2ban/
│   └── zap/
│
├── .github/
│   └── workflows/
│       └── pipeline.yml    # CI/CD pipeline definition
│
└── docs/                   # Architecture diagrams & documentation
```

---

## 🚀 Getting Started

### Prerequisites

- Docker & Docker Compose
- `kubectl` configured with a Kubernetes cluster (minikube, k3s, or cloud)
- Terraform ≥ 1.3
- A GitHub account (for Actions)

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/SafePipeline.git
cd SafePipeline
```

### 2. Configure environment variables

```bash
cp .env.example .env
# Edit .env with your settings (DB credentials, cluster endpoint, etc.)
```

### 3. Provision infrastructure

```bash
cd infra/
terraform init
terraform apply
```

### 4. Deploy to Kubernetes

```bash
kubectl apply -f k8s/
kubectl get pods -w
```

### 5. Start the monitoring stack

```bash
kubectl apply -f monitoring/
# Access Grafana at http://<cluster-ip>:3000
```

### 6. Access the application

```bash
kubectl get ingress
# Navigate to the displayed external IP
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

| Role | Responsibilities |
|---|---|
| **Security Engineer** | Attack simulation, Wazuh setup, Fail2Ban rules, log analysis, ZAP integration |
| **Developer** | Web application, API, unit tests, Docker, CI/CD pipeline |

*Shared:* Kubernetes, Terraform, architecture design, documentation.

---

## 📄 License

This project is intended for **educational purposes only**.  
All vulnerabilities are introduced intentionally in a controlled environment.

---

<div align="center">

**SafePipeline** — *Secure by design, vulnerable by intent.*

</div>
