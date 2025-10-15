output "kubeconfig" {
  description = "Kubeconfig file for the Talos cluster."
  value       = module.talos_cluster.kubeconfig
  sensitive   = true
}

output "talos_config" {
  description = "Talos configuration"
  value       = module.talos_cluster.talos_config
  sensitive   = true
}
