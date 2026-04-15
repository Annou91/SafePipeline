terraform {
  required_version = ">= 1.3"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }
}

# -------------------------------------------------------------------
# Provider — connect to local Kubernetes cluster (minikube)
# -------------------------------------------------------------------
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

# -------------------------------------------------------------------
# Namespace — app
# -------------------------------------------------------------------
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace
    labels = {
      project     = "safepipeline"
      environment = var.environment
    }
  }
}

# -------------------------------------------------------------------
# Namespace — monitoring
# -------------------------------------------------------------------
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
    labels = {
      project     = "safepipeline"
      environment = var.environment
    }
  }
}

# -------------------------------------------------------------------
# Namespace — security
# -------------------------------------------------------------------
resource "kubernetes_namespace" "security" {
  metadata {
    name = var.security_namespace
    labels = {
      project     = "safepipeline"
      environment = var.environment
    }
  }
}

# -------------------------------------------------------------------
# ConfigMap — app config
# -------------------------------------------------------------------
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    FLASK_ENV  = var.environment
    APP_PORT   = "5000"
    LOG_LEVEL  = "INFO"
  }
}
