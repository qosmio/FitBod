<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.28.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.6.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.12.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_db"></a> [db](#module\_db) | GoogleCloudPlatform/sql-db/google//modules/postgresql | >= 11.0.0 |
| <a name="module_gcp_network"></a> [gcp\_network](#module\_gcp\_network) | terraform-google-modules/network/google | >= 5.1.0 |
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster | >= v22.0.0 |
| <a name="module_gke_auth"></a> [gke\_auth](#module\_gke\_auth) | terraform-google-modules/kubernetes-engine/google//modules/auth | >= v22.0.0 |
| <a name="module_private_service_access"></a> [private\_service\_access](#module\_private\_service\_access) | GoogleCloudPlatform/sql-db/google//modules/private_service_access | >= 11.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.ingress_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk.monitoring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_project_service.services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [helm_release.nginx_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role_binding.cilium_node_patcher](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.grafana_dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_deployment.app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.ingress_app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_job.grafana_set_main_dash](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_job.init_app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_persistent_volume.app_pv](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume.grafana_pv](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume.prom_pv](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume_claim.app_pvc](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_secret.app_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.db](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.grafana](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.app_frontend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [null_resource.kubectl](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.app_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.grafana_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [local_file.masterkey](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_image_name"></a> [app\_image\_name](#input\_app\_image\_name) | Container image to use | `string` | n/a | yes |
| <a name="input_app_master_key_file"></a> [app\_master\_key\_file](#input\_app\_master\_key\_file) | Rails master key file. This will populate the `RAILS_MASTER_KEY` environment variable | `string` | `""` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name | `string` | n/a | yes |
| <a name="input_app_user_pass"></a> [app\_user\_pass](#input\_app\_user\_pass) | List of users to reset password for | <pre>map(object({<br>    email    = string<br>    password = string<br>  }))</pre> | n/a | yes |
| <a name="input_db_availability_type"></a> [db\_availability\_type](#input\_db\_availability\_type) | The availability type for the master instance.This is only used to set up high availability for the PostgreSQL instance. Can be either `ZONAL` or `REGIONAL`. | `string` | n/a | yes |
| <a name="input_db_create_timeout"></a> [db\_create\_timeout](#input\_db\_create\_timeout) | The optional timout that is applied to limit long database creates. | `string` | `"15m"` | no |
| <a name="input_db_delete_timeout"></a> [db\_delete\_timeout](#input\_db\_delete\_timeout) | The optional timout that is applied to limit long database deletes. | `string` | `"5m"` | no |
| <a name="input_db_deletion_protection"></a> [db\_deletion\_protection](#input\_db\_deletion\_protection) | Used to block Terraform from deleting a SQL Instance. | `bool` | `false` | no |
| <a name="input_db_disk_autoresize"></a> [db\_disk\_autoresize](#input\_db\_disk\_autoresize) | Configuration to increase storage size. | `bool` | `true` | no |
| <a name="input_db_disk_size_gb"></a> [db\_disk\_size\_gb](#input\_db\_disk\_size\_gb) | The disk size for the master instance. | `number` | `10` | no |
| <a name="input_db_disk_type"></a> [db\_disk\_type](#input\_db\_disk\_type) | The disk type for the master instance PD\_SSD or PD\_HDD. | `string` | n/a | yes |
| <a name="input_db_enable_default_db"></a> [db\_enable\_default\_db](#input\_db\_enable\_default\_db) | Enable or disable the creation of the default database | `bool` | `true` | no |
| <a name="input_db_enable_default_user"></a> [db\_enable\_default\_user](#input\_db\_enable\_default\_user) | Enable or disable the creation of the default user | `bool` | `true` | no |
| <a name="input_db_tier"></a> [db\_tier](#input\_db\_tier) | The tier for the master instance. | `string` | `"db-g1-small"` | no |
| <a name="input_db_update_timeout"></a> [db\_update\_timeout](#input\_db\_update\_timeout) | The optional timout that is applied to limit long database updates. | `string` | `"5m"` | no |
| <a name="input_db_user"></a> [db\_user](#input\_db\_user) | The database user | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, prod, etc) | `string` | n/a | yes |
| <a name="input_gce_disk_size_gb"></a> [gce\_disk\_size\_gb](#input\_gce\_disk\_size\_gb) | The disk size for persistent storage | `number` | n/a | yes |
| <a name="input_gce_disk_type"></a> [gce\_disk\_type](#input\_gce\_disk\_type) | The disk type for the master instance PD-SSD or PD-HDD. | `string` | n/a | yes |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The region to create the cluster/compute nodes. | `string` | `null` | no |
| <a name="input_gcp_zones"></a> [gcp\_zones](#input\_gcp\_zones) | The zones to create the cluster/compute nodes. | `list(any)` | n/a | yes |
| <a name="input_gke_dataplane_v2_enabled"></a> [gke\_dataplane\_v2\_enabled](#input\_gke\_dataplane\_v2\_enabled) | Enable Dataplane V2 otherwise use iptables based firewall | `bool` | `true` | no |
| <a name="input_gke_disk_size_gb"></a> [gke\_disk\_size\_gb](#input\_gke\_disk\_size\_gb) | The disk size in gigabytes for the GKE nodes | `number` | n/a | yes |
| <a name="input_gke_disk_type"></a> [gke\_disk\_type](#input\_gke\_disk\_type) | The disk type for the GKE nodes. Valid values are PD-SSD,PD-Standard,PD-Balanced,PD-LocalSSD | `string` | n/a | yes |
| <a name="input_gke_enable_preemptible"></a> [gke\_enable\_preemptible](#input\_gke\_enable\_preemptible) | Whether to enable preemptible nodes | `bool` | n/a | yes |
| <a name="input_gke_image_type"></a> [gke\_image\_type](#input\_gke\_image\_type) | The image type to use for GKE nodes | `string` | `"COS_CONTAINERD"` | no |
| <a name="input_gke_is_regional"></a> [gke\_is\_regional](#input\_gke\_is\_regional) | Whether to enable a regional cluster | `bool` | n/a | yes |
| <a name="input_gke_machine_type"></a> [gke\_machine\_type](#input\_gke\_machine\_type) | Machine type for GKE nodes | `string` | n/a | yes |
| <a name="input_gke_max_cpu_cores"></a> [gke\_max\_cpu\_cores](#input\_gke\_max\_cpu\_cores) | Maximum number of CPU cores to use for GKE nodes | `number` | n/a | yes |
| <a name="input_gke_max_memory_gb"></a> [gke\_max\_memory\_gb](#input\_gke\_max\_memory\_gb) | The max memory in gigabytes for the GKE nodes | `number` | n/a | yes |
| <a name="input_gke_max_num_nodes"></a> [gke\_max\_num\_nodes](#input\_gke\_max\_num\_nodes) | Max number of GKE nodes | `number` | n/a | yes |
| <a name="input_gke_min_cpu_cores"></a> [gke\_min\_cpu\_cores](#input\_gke\_min\_cpu\_cores) | Minimum number of CPU cores to use for GKE nodes | `number` | n/a | yes |
| <a name="input_gke_min_memory_gb"></a> [gke\_min\_memory\_gb](#input\_gke\_min\_memory\_gb) | Minimum memory in gigabytes to use for GKE nodes | `number` | n/a | yes |
| <a name="input_gke_min_num_nodes"></a> [gke\_min\_num\_nodes](#input\_gke\_min\_num\_nodes) | Min number of GKE nodes | `number` | n/a | yes |
| <a name="input_gke_version"></a> [gke\_version](#input\_gke\_version) | GKE Kubernetes version | `string` | `"1.24.1-gke.1800"` | no |
| <a name="input_pg_name"></a> [pg\_name](#input\_pg\_name) | The name of the Cloud SQL resources | `string` | n/a | yes |
| <a name="input_pg_version"></a> [pg\_version](#input\_pg\_version) | The database version to use. (Fitbod 'myworkout' uses PostgreSQL client version 13 even though 14 is the latest) | `string` | `"POSTGRES_14"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project Name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_pass"></a> [admin\_pass](#output\_admin\_pass) | Admin rails password for admin@example.com |
| <a name="output_app_url"></a> [app\_url](#output\_app\_url) | The URL of the deployed FitBod rails application |
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | Cluster ca certificate (base64 encoded) |
| <a name="output_db_host"></a> [db\_host](#output\_db\_host) | The private IP address of the database |
| <a name="output_db_pass"></a> [db\_pass](#output\_db\_pass) | The generated password of the database |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Cluster endpoint |
| <a name="output_gcp_region"></a> [gcp\_region](#output\_gcp\_region) | Cluster region |
| <a name="output_gke_cluster_type"></a> [gke\_cluster\_type](#output\_gke\_cluster\_type) | Cluster type (regional / zonal) |
| <a name="output_gke_name"></a> [gke\_name](#output\_gke\_name) | Cluster name |
| <a name="output_grafana_pass"></a> [grafana\_pass](#output\_grafana\_pass) | Grafana admin password |
| <a name="output_grafana_url"></a> [grafana\_url](#output\_grafana\_url) | The URL of the deployed Grafana instance |
| <a name="output_grafana_user"></a> [grafana\_user](#output\_grafana\_user) | Grafana admin user |
| <a name="output_horizontal_pod_autoscaling_enabled"></a> [horizontal\_pod\_autoscaling\_enabled](#output\_horizontal\_pod\_autoscaling\_enabled) | Whether horizontal pod autoscaling enabled |
| <a name="output_http_load_balancing_enabled"></a> [http\_load\_balancing\_enabled](#output\_http\_load\_balancing\_enabled) | Whether http load balancing enabled |
| <a name="output_location"></a> [location](#output\_location) | Cluster location (region if regional cluster, zone if zonal cluster) |
| <a name="output_logging_service"></a> [logging\_service](#output\_logging\_service) | Logging service used |
| <a name="output_master_authorized_networks_config"></a> [master\_authorized\_networks\_config](#output\_master\_authorized\_networks\_config) | Networks from which access to master is permitted |
| <a name="output_master_version"></a> [master\_version](#output\_master\_version) | Current master kubernetes version |
| <a name="output_min_master_version"></a> [min\_master\_version](#output\_min\_master\_version) | Minimum master kubernetes version |
| <a name="output_monitoring_service"></a> [monitoring\_service](#output\_monitoring\_service) | Monitoring service used |
| <a name="output_network_module"></a> [network\_module](#output\_network\_module) | network module output |
| <a name="output_network_policy_enabled"></a> [network\_policy\_enabled](#output\_network\_policy\_enabled) | Whether network policy enabled |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The service account to default running nodes as if not overridden in `node_pools`. |
| <a name="output_subnets_ips"></a> [subnets\_ips](#output\_subnets\_ips) | The IP and cidrs of the subnets being created |
| <a name="output_subnets_secondary_ranges"></a> [subnets\_secondary\_ranges](#output\_subnets\_secondary\_ranges) | The secondary ranges associated with these subnets |
| <a name="output_user1_pass"></a> [user1\_pass](#output\_user1\_pass) | User password for user1@fitbod.me |
| <a name="output_vpc_network_out"></a> [vpc\_network\_out](#output\_vpc\_network\_out) | The network name of the VPC |
| <a name="output_vpc_subnet_out"></a> [vpc\_subnet\_out](#output\_vpc\_subnet\_out) | The subnet name of the VPC |

<!-- END_TF_DOCS -->
