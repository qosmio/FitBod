locals {
  # construct region from list of zones. Zones should all be in the same region.
  gke_net    = "${var.environment}-${var.project_name}-net"
  gke_subnet = "${var.environment}-${var.project_name}-subnet"
  gcp_secondary_range = [
    {
      range_name    = "ip-range-pods"
      ip_cidr_range = "10.20.0.0/16"
    },
    {
      range_name    = "ip-range-services"
      ip_cidr_range = "10.30.0.0/16"
    },
  ]
}


module "gcp_network" {
  source       = "terraform-google-modules/network/google"
  version      = ">= 5.1.0"
  project_id   = var.project_id
  network_name = local.gke_net

  subnets = [
    {
      subnet_name   = "${local.gke_subnet}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = "${local.gcp_region}"
    },
  ]
  secondary_ranges = {
    "${local.gke_subnet}" = local.gcp_secondary_range
  }
}

