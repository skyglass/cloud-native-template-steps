helm uninstall cert-manager --namespace public-ingress
helm uninstall ingress-nginx --namespace public-ingress
terraform destroy --auto-approve