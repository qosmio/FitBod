environment = "prod"

db_availability_type   = "REGIONAL"
db_deletion_protection = false
db_disk_autoresize     = true
db_disk_size_gb        = 10
db_disk_type           = "PD_SSD"
db_tier                = "db-g1-small"

gcp_zones  = ["us-east1-d", "us-east1-c", "us-east1-b"]
gcp_region = "us-east1"

gce_disk_size_gb = 5
gce_disk_type    = "pd-ssd"

gke_disk_size_gb       = 50
gke_disk_type          = "pd-ssd"
gke_machine_type       = "e2-highcpu-4"
gke_max_cpu_cores      = 8
gke_max_memory_gb      = 8
gke_max_num_nodes      = 8
gke_min_cpu_cores      = 2
gke_min_memory_gb      = 2
gke_min_num_nodes      = 2
gke_is_regional        = true
gke_enable_preemptible = false
