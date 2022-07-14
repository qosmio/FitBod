output "gke_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "gke_cluster_type" {
  description = "Cluster type (regional / zonal)"
  value       = module.gke.type
}

output "location" {
  description = "Cluster location (region if regional cluster, zone if zonal cluster)"
  value       = module.gke.location
}

output "gcp_region" {
  description = "Cluster region"
  value       = local.gcp_region
}

output "endpoint" {
  sensitive   = true
  description = "Cluster endpoint"
  value       = module.gke.endpoint
}

output "min_master_version" {
  description = "Minimum master kubernetes version"
  value       = module.gke.min_master_version
}

output "logging_service" {
  description = "Logging service used"
  value       = module.gke.logging_service
}

output "monitoring_service" {
  description = "Monitoring service used"
  value       = module.gke.monitoring_service
}

output "master_authorized_networks_config" {
  description = "Networks from which access to master is permitted"
  value       = module.gke.master_authorized_networks_config
}

output "master_version" {
  description = "Current master kubernetes version"
  value       = module.gke.master_version
}

output "ca_certificate" {
  sensitive   = true
  description = "Cluster ca certificate (base64 encoded)"
  value       = module.gke.ca_certificate
}

output "network_policy_enabled" {
  description = "Whether network policy enabled"
  value       = module.gke.network_policy_enabled
}

output "http_load_balancing_enabled" {
  description = "Whether http load balancing enabled"
  value       = module.gke.http_load_balancing_enabled
}

output "horizontal_pod_autoscaling_enabled" {
  description = "Whether horizontal pod autoscaling enabled"
  value       = module.gke.horizontal_pod_autoscaling_enabled
}

output "service_account" {
  description = "The service account to default running nodes as if not overridden in `node_pools`."
  value       = module.gke.service_account
}

output "network_module" {
  description = "network module output"
  value       = module.gcp_network
}

output "subnets_ips" {
  description = "The IP and cidrs of the subnets being created"
  value       = module.gcp_network.subnets_ips
}

output "subnets_secondary_ranges" {
  description = "The secondary ranges associated with these subnets"
  value       = module.gcp_network.subnets_secondary_ranges
}

output "vpc_network_out" {
  description = "The network name of the VPC"
  value       = module.gcp_network.network_name
}

output "vpc_subnet_out" {
  description = "The subnet name of the VPC"
  value       = module.gcp_network.subnets_names[0]
}

output "db_host" {
  description = "The private IP address of the database"
  value       = module.db.private_ip_address
}

output "db_pass" {
  description = "The generated password of the database"
  value       = module.db.generated_user_password
  sensitive   = true
}

output "grafana_user" {
  description = "Grafana admin user"
  value       = kubernetes_secret.grafana.data.admin-user
  sensitive   = true
}

output "grafana_pass" {
  description = "Grafana admin password"
  value       = kubernetes_secret.grafana.data.admin-pass
  sensitive   = true
}

output "admin_pass" {
  description = "Admin rails password for admin@example.com"
  value       = random_password.app_pass["admin"].result
  sensitive   = true
}

output "user1_pass" {
  description = "User password for user1@fitbod.me"
  value       = random_password.app_pass["user1"].result
  sensitive   = true
}

output "app_url" {
  description = "The URL of the deployed FitBod rails application"
  value       = "http://${google_compute_address.ingress_ip.address}/"
}

output "grafana_url" {
  description = "The URL of the deployed Grafana instance"
  value       = "http://${google_compute_address.ingress_ip.address}/grafana"
}
