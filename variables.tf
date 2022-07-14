variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc)"
  type        = string
}

# DB variables
variable "pg_name" {
  type        = string
  description = "The name of the Cloud SQL resources"
}

variable "pg_version" {
  description = "The database version to use. (Fitbod 'myworkout' uses PostgreSQL client version 13 even though 14 is the latest)"
  type        = string
  default     = "POSTGRES_14"
}

variable "db_user" {
  description = "The database user"
  type        = string
}

variable "db_tier" {
  description = "The tier for the master instance."
  type        = string
  default     = "db-g1-small"
}

variable "db_availability_type" {
  description = "The availability type for the master instance.This is only used to set up high availability for the PostgreSQL instance. Can be either `ZONAL` or `REGIONAL`."
  type        = string
}

variable "db_disk_autoresize" {
  description = "Configuration to increase storage size."
  default     = true
  type        = bool
}

variable "db_disk_size_gb" {
  description = "The disk size for the master instance."
  default     = 10
  type        = number
}

variable "db_disk_type" {
  description = "The disk type for the master instance PD_SSD or PD_HDD."
  type        = string
}

variable "db_create_timeout" {
  description = "The optional timout that is applied to limit long database creates."
  type        = string
  default     = "15m"
}

variable "db_update_timeout" {
  description = "The optional timout that is applied to limit long database updates."
  type        = string
  default     = "5m"
}

variable "db_delete_timeout" {
  description = "The optional timout that is applied to limit long database deletes."
  type        = string
  default     = "5m"
}

variable "db_deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance."
  default     = false
  type        = bool
}

variable "db_enable_default_db" {
  description = "Enable or disable the creation of the default database"
  default     = true
  type        = bool
}

variable "db_enable_default_user" {
  description = "Enable or disable the creation of the default user"
  default     = true
  type        = bool
}

# GCP Google Cloud Platform
variable "gcp_zones" {
  description = "The zones to create the cluster/compute nodes."
  type        = list(any)
}

variable "gcp_region" {
  description = "The region to create the cluster/compute nodes."
  type        = string
  default     = null
}

# GCD Google Compute Engine Disk
variable "gce_disk_size_gb" {
  description = "The disk size for persistent storage"
  type        = number
}

variable "gce_disk_type" {
  description = "The disk type for the master instance PD-SSD or PD-HDD."
  type        = string
}

# GKE cluster
variable "gke_min_num_nodes" {
  description = "Min number of GKE nodes"
  type        = number
}

variable "gke_max_num_nodes" {
  description = "Max number of GKE nodes"
  type        = number
}

variable "gke_version" {
  description = "GKE Kubernetes version"
  type        = string
  default     = "1.24.1-gke.1800"
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
}

variable "gke_dataplane_v2_enabled" {
  default     = true
  description = "Enable Dataplane V2 otherwise use iptables based firewall"
  type        = bool
}

variable "gke_disk_size_gb" {
  description = "The disk size in gigabytes for the GKE nodes"
  type        = number
}

variable "gke_min_cpu_cores" {
  description = "Minimum number of CPU cores to use for GKE nodes"
  type        = number
}

variable "gke_max_cpu_cores" {
  description = "Maximum number of CPU cores to use for GKE nodes"
  type        = number
}

variable "gke_min_memory_gb" {
  description = "Minimum memory in gigabytes to use for GKE nodes"
  type        = number
}

variable "gke_max_memory_gb" {
  description = "The max memory in gigabytes for the GKE nodes"
  type        = number
}

variable "gke_disk_type" {
  description = "The disk type for the GKE nodes. Valid values are PD-SSD,PD-Standard,PD-Balanced,PD-LocalSSD"
  type        = string
}

variable "gke_image_type" {
  description = "The image type to use for GKE nodes"
  default     = "COS_CONTAINERD"
  type        = string
}

variable "gke_is_regional" {
  description = "Whether to enable a regional cluster"
  type        = bool
}

variable "gke_enable_preemptible" {
  description = "Whether to enable preemptible nodes"
  type        = bool
}

# APP
variable "app_name" {
  type        = string
  description = "Application name"
}

variable "app_master_key_file" {
  type        = string
  description = "Rails master key file. This will populate the `RAILS_MASTER_KEY` environment variable"
  default     = ""
}

variable "app_user_pass" {
  description = "List of users to reset password for"
  type = map(object({
    email    = string
    password = string
  }))
}

variable "app_image_name" {
  description = "Container image to use"
  type        = string
}
