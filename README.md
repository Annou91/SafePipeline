# DevSecOps Platform

## Description

This project is a complete DevSecOps platform designed to demonstrate the integration of development, security, and operations within a modern cloud-native environment.

It includes a deliberately vulnerable web application deployed through an automated CI/CD pipeline, with integrated monitoring and real-time security analysis.

The goal is to simulate real-world scenarios where applications are continuously built, tested, deployed, monitored, and secured.

---

## Objectives

- Implement a full DevSecOps workflow
- Automate build, test, security scanning, and deployment
- Monitor system and application performance
- Detect and analyze cyber attacks in real time
- Apply both offensive and defensive security techniques

---

## Technologies Used

### Containerization
- Docker

### Orchestration
- Kubernetes

### CI/CD
- GitHub Actions

### Infrastructure as Code
- Terraform

### Monitoring
- Prometheus
- Grafana

### Security
- OWASP ZAP (vulnerability scanning)
- Wazuh (SIEM, log analysis, intrusion detection)
- Fail2Ban (automatic IP blocking)

---

## Application

The project includes a simple web application with authentication features and intentionally introduced vulnerabilities for testing purposes:

- SQL Injection
- Cross-Site Scripting (XSS)
- Weak authentication mechanisms

---

## CI/CD Pipeline

The pipeline is automatically triggered on each code push and includes the following stages:

1. Build the application  
2. Run tests  
3. Perform security scans (SAST/DAST with OWASP ZAP)  
4. Build Docker image  
5. Deploy to Kubernetes  

---

## Deployment

The application is deployed on a Kubernetes cluster with:

- Deployments  
- Services  
- Ingress configuration  

Infrastructure provisioning is automated using Terraform.

---

## Monitoring

- Prometheus collects system and application metrics  
- Grafana provides dashboards for visualization  

Metrics include CPU usage, memory usage, traffic, and error rates.

---

## Security and Attack Detection

Simulated attacks include:

- Brute force login attempts  
- SQL injection attacks  
- Port scanning  

Security tools provide:

- Log collection and analysis (Wazuh)  
- Alert generation  
- Automatic blocking of malicious IPs (Fail2Ban)  

---

## Project Structure

/app – Application source code  
/k8s – Kubernetes manifests  
/infra – Terraform configuration  
/monitoring – Prometheus & Grafana setup  
/security – Wazuh, Fail2Ban, ZAP configs  
/docs – Documentation  

---

## Team Work

This project is developed by two contributors:

- Security: attack simulation, detection, log analysis, protection mechanisms  
- Development: application, API, testing  

Shared responsibilities include Docker, Kubernetes, CI/CD, and infrastructure.

---

## Getting Started

1. Clone the repository  
2. Configure environment variables  
3. Build and run the application using Docker  
4. Deploy infrastructure using Terraform  
5. Apply Kubernetes manifests  
6. Access monitoring dashboards and security tools  

---

## Expected Outcome

A fully functional DevSecOps platform capable of:

- Continuous integration and deployment  
- Real-time monitoring  
- Automated vulnerability detection  
- Active defense against cyber attacks
