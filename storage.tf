resource "kubernetes_persistent_volume" "prom_pv" {
  metadata {
    name = "prom-pv"
  }
  spec {
    capacity = {
      storage = "0.25"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.monitoring.name
        fs_type = "ext4"
      }
    }
    storage_class_name = "standard-rwo"
  }
}

resource "kubernetes_persistent_volume" "grafana_pv" {
  metadata {
    name = "grafana-pv"
  }
  spec {
    capacity = {
      storage = "0.25"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.monitoring.name
        fs_type = "ext4"
      }
    }
    storage_class_name = "standard"
  }
}

# resource "kubernetes_persistent_volume_claim" "grafana_pvc" {
#   metadata {
#     name = "grafana-pvc"
#   }
#   wait_until_bound = true
#   spec {
#     access_modes = ["ReadWriteMany"]
#     resources {
#       requests = {
#         storage = "0.25"
#       }
#     }
#     storage_class_name = "standard"
#     volume_name        = kubernetes_persistent_volume.grafana_pv.metadata[0].name
#   }
# }

resource "google_compute_disk" "monitoring" {
  project = var.project_id
  zone    = var.gcp_zones[0]
  name    = "monitoring"
  type    = var.gce_disk_type
  size    = 2
}

resource "kubernetes_persistent_volume_claim" "app_pvc" {
  metadata {
    name = "app-pvc"
  }
  wait_until_bound = true
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "0.25"
      }
    }
    storage_class_name = "standard"
    volume_name        = kubernetes_persistent_volume.app_pv.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "app_pv" {
  metadata {
    name = "app-pv"
  }
  spec {
    capacity = {
      storage = "0.25"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.app.name
        fs_type = "ext4"
      }
    }
    storage_class_name = "standard"
  }
}

resource "google_compute_disk" "app" {
  project = var.project_id
  zone    = var.gcp_zones[0]
  name    = "app"
  type    = var.gce_disk_type
  size    = 1
}
