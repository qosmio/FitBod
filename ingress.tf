locals {
  ns_ingress = "ingress-nginx"
}

resource "helm_release" "nginx_controller" {
  # atomic = true
  chart            = "ingress-nginx"
  depends_on       = [google_compute_address.ingress_ip, helm_release.prometheus]
  create_namespace = true
  name             = local.ns_ingress
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  timeout          = 60
  # force_update = true
  values = [templatefile("${path.module}/config/values/ingress.yaml", { external_ip = google_compute_address.ingress_ip.address })]
}

resource "google_compute_address" "ingress_ip" {
  provider = google
  name     = "${var.project_name}-ingress-ip"
  region   = local.gcp_region

  depends_on = [
    module.gcp_network
  ]
}

resource "kubernetes_ingress_v1" "ingress_app" {
  wait_for_load_balancer = true
  depends_on             = [helm_release.nginx_controller]
  metadata {
    name = local.ns_ingress
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/server-snippet" = "set_real_ip_from 0.0.0.0/0; real_ip_header X-Forwarded-For;"
    }
  }

  spec {
    # ingress_class_name = kubernetes_ingress_class_v1.ingress_nginx.metadata[0].name
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app_frontend.metadata[0].name
              port {
                number = kubernetes_service.app_frontend.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }
}
