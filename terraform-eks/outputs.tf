output "update_config_command" {
  value       = "aws eks update-kubeconfig --region ${local.region} --name ${local.name}"
}
