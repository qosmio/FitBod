resource "kubernetes_secret" "db" {
  depends_on = [module.db]
  metadata {
    name = "db"
  }
  data = {
    admin-pass = module.db.generated_user_password
    admin-user = var.db_user
  }
  type = "Opaque"
}

module "private_service_access" {
  depends_on  = [module.gcp_network]
  source      = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version     = ">= 11.0.0"
  project_id  = var.project_id
  vpc_network = module.gcp_network.network_name
}

module "db" {
  source               = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version              = ">= 11.0.0"
  random_instance_name = true
  project_id           = var.project_id
  zone                 = var.db_availability_type == "ZONAL" ? var.gcp_zones[0] : ""
  region               = local.gcp_region
  name                 = var.pg_name
  database_version     = var.pg_version
  tier                 = var.db_tier
  availability_type    = var.db_availability_type
  disk_autoresize      = var.db_disk_autoresize
  disk_size            = var.db_disk_size_gb
  disk_type            = var.db_disk_type
  user_name            = var.db_user

  ip_configuration = {
    private_network     = module.gcp_network.network_self_link
    ipv4_enabled        = false
    require_ssl         = false
    allocated_ip_range  = null
    authorized_networks = []
  }

  create_timeout      = var.db_create_timeout
  update_timeout      = var.db_update_timeout
  delete_timeout      = var.db_delete_timeout
  deletion_protection = var.db_deletion_protection
  enable_default_db   = var.db_enable_default_db
  enable_default_user = var.db_enable_default_user
  module_depends_on   = [module.private_service_access.peering_completed]
}
