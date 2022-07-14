locals {
  # construct region from list of zones. Zones should all be in the same region.
  gcp_region   = var.gcp_region == "" || var.gcp_region == null ? join("-", slice(split("-", var.gcp_zones[0]), 0, 2)) : var.gcp_region
  kube_context = var.gke_is_regional == false ? "--zone ${var.gcp_zones[0]}" : "--region  ${var.gcp_region}"
  gke_name     = "${var.environment}-${var.project_name}-gke"
  gke_pool     = "${var.environment}-${var.project_name}-pool"
}

module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                           = ">= v22.0.0"
  project_id                        = var.project_id
  name                              = local.gke_name
  regional                          = var.gke_is_regional
  region                            = local.gcp_region
  zones                             = var.gcp_zones
  network                           = module.gcp_network.network_name
  subnetwork                        = module.gcp_network.subnets_names[0]
  ip_range_pods                     = "ip-range-pods"
  ip_range_services                 = "ip-range-services"
  disable_legacy_metadata_endpoints = true
  horizontal_pod_autoscaling        = true
  # Make use of eBPF for improved network scalability.
  datapath_provider                    = var.gke_dataplane_v2_enabled ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"
  http_load_balancing                  = false
  gce_pd_csi_driver                    = true
  remove_default_node_pool             = true
  add_master_webhook_firewall_rules    = true
  enable_private_endpoint              = true
  enable_private_nodes                 = false
  kubernetes_version                   = var.gke_version
  monitoring_enable_managed_prometheus = false

  cluster_autoscaling = {
    enabled             = true
    autoscaling_profile = "BALANCED"
    max_cpu_cores       = var.gke_max_cpu_cores
    min_cpu_cores       = var.gke_min_cpu_cores
    max_memory_gb       = var.gke_max_memory_gb
    min_memory_gb       = var.gke_min_memory_gb
    gpu_resources       = []
  }

  node_pools = [
    {
      name               = local.gke_pool
      min_master_version = var.gke_version
      machine_type       = var.gke_machine_type
      node_locations     = join(",", var.gcp_zones)
      min_count          = var.gke_min_num_nodes
      max_count          = var.gke_max_num_nodes
      disk_size_gb       = var.gke_disk_size_gb
      tags               = "gke-node, ${var.project_name}-gke"
      disk_type          = var.gke_disk_type
      image_type         = var.gke_image_type
      preemptible        = var.gke_enable_preemptible
      initial_node_count = 1
      auto_upgrade       = true
      autoscaling        = true
    },
  ]
  node_pools_oauth_scopes = {
    # all = []
    "${local.gke_pool}" = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/compute",
    ]
  }


  node_pools_labels = {
    # all = {}
    "${local.gke_pool}" = {
      "${local.gke_pool}" = true
    }
  }

  node_pools_taints = {
    # all = []
    "${local.gke_pool}" = [
      {
        key    = local.gke_pool
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    # all = []
    "${local.gke_pool}" = [
      local.gke_pool,
    ]
  }
}

module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = ">= v22.0.0"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = local.gke_name
}

# Fix for 'unable to patch node resource with annotation' error
# Cilium is used for eBPF-based traffic shaping. (gke_dataplane_v2_enabled=true)
resource "kubernetes_cluster_role_binding" "cilium_node_patcher" {
  metadata {
    name = "cilium-node-patcher"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cilium"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:node"
  }
}

# Retrieve Cluster Credentials
resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    environment = {
      "USE_GKE_GCLOUD_AUTH_PLUGIN" = "True"
    }
    # Automatically update local gcloud config after provisioning
    command = <<EOT
      gcloud config set compute/zone ${var.gcp_zones[0]}
      gcloud config set compute/region ${local.gcp_region}
      gcloud container clusters get-credentials ${local.gke_name} ${local.kube_context} --project ${var.project_id}
    EOT
  }
  depends_on = [module.gke_auth]
}
