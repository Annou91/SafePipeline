variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use (e.g. minikube)"
  type        = string
  default     = "minikube"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "app_namespace" {
  description = "Namespace for the web application"
  type        = string
  default     = "safepipeline"
}

variable "monitoring_namespace" {
  description = "Namespace for Prometheus and Grafana"
  type        = string
  default     = "monitoring"
}

variable "security_namespace" {
  description = "Namespace for Wazuh and security tools"
  type        = string
  default     = "security"
}
