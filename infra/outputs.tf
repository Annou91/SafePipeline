output "app_namespace" {
  description = "Namespace where the app is deployed"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "monitoring_namespace" {
  description = "Namespace for monitoring tools"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "security_namespace" {
  description = "Namespace for security tools"
  value       = kubernetes_namespace.security.metadata[0].name
}
