environment = "dev"

db_availability_type   = "ZONAL"
db_deletion_protection = false
db_disk_autoresize     = false
db_disk_type           = "PD_HDD"
db_tier                = "db-g1-small"

gcp_zones = ["us-east1-d"]

gce_disk_size_gb = 2
gce_disk_type    = "pd-balanced"

gke_disk_size_gb = 50
gke_disk_type    = "pd-ssd"
gke_machine_type = "e2-highcpu-4"
#gke_machine_type      = "e2-medium"
gke_max_cpu_cores      = 4
gke_max_memory_gb      = 8
gke_max_num_nodes      = 8
gke_min_cpu_cores      = 2
gke_min_memory_gb      = 2
gke_min_num_nodes      = 1
gke_is_regional        = false
gke_enable_preemptible = true
