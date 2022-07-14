resource "random_password" "grafana_pass" {
  length           = 16
  special          = true
  override_special = "!%&?"
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name = "grafana"
  }

  data = {
    admin-pass = random_password.grafana_pass.result
    admin-user = "grafana-adm"
  }

  type = "Opaque"
}

resource "helm_release" "prometheus" {
  depends_on       = [google_compute_disk.monitoring]
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  force_update     = true
  namespace        = "monitoring"
  cleanup_on_fail  = true
  create_namespace = true
  values = [
    templatefile("${path.root}/config/values/monitoring.yaml", {
      admin_pass = kubernetes_secret.grafana.data.admin-pass
      admin_user = kubernetes_secret.grafana.data.admin-user
      prom_pv    = kubernetes_persistent_volume.prom_pv
      grafana_pv = kubernetes_persistent_volume.grafana_pv
    })
  ]
  timeout = 120
}

resource "kubernetes_config_map" "grafana_dashboards" {
  depends_on = [helm_release.prometheus]
  metadata {
    name      = "grafana-dashboards"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    # "fitbod-k8s.json" = ""
    "fitbod-k8s.json" = file("${path.root}/config/grafana/dashboards/fitbod-k8s.json")
  }
}

resource "kubernetes_job" "grafana_set_main_dash" {
  count      = 1
  depends_on = [helm_release.prometheus, kubernetes_secret.grafana]
  timeouts {
    create = "1m"
    delete = "2m"
  }
  metadata {
    name      = "prometheus-grafana"
    namespace = "monitoring"
    labels = {
      "meta.helm.sh/release-name"      = "prometheus"
      "meta.helm.sh/release-namespace" = "monitoring"
    }
    annotations = {
      "helm.sh/hook"                 = "post-install"
      "helm.sh/hook-delete-policy"   = "hook-succeeded"
      "helm.sh/hook-weight"          = "-5"
      "app.kubernetes.io/instance"   = "prometheus"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "grafana"
    }
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name              = "prometheus-grafana-set-main-dash"
          image             = "appropriate/curl:latest"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [<<-EOT
            #!/bin/sh
            host="${google_compute_address.ingress_ip.address}"
            port=80
            user="${kubernetes_secret.grafana.data.admin-user}"
            pass="${kubernetes_secret.grafana.data.admin-pass}"
            url="http://$user:$pass@$host:$port/grafana"
            parse_json() {
              echo "$1" | sed "s/.*\"$2\":\([^,}]*\).*/\1/;s/\"//g"
            }
            # loop until reply is valid
            until [ "$(curl -s -o /dev/null -w '%%{http_code}' $url/api/datasources)" = "200" ]; do
              echo "Waiting for Grafana to be ready..."
              sleep 1
            done
            rep=$(curl -s -X GET -H "Content-Type: application/json" "$url/api/search?query=FitBod")
            dash_id=$(parse_json "$rep" "id")
            curl -X 'PUT' -H "Content-Type: application/json" --data-raw '{"homeDashboardId":'"$dash_id"'}' "$url/api/user/preferences"
          EOT
          ]
          # args = [<<EOT
          #         sqlite3 /var/lib/grafana/grafana.db "create unique index if not exists preferences_uid_pk on preferences(user_id);
          #         INSERT INTO preferences(
          #             org_id ,user_id ,version ,home_dashboard_id
          #            ,timezone, theme, created, updated, team_id
          #           )
          #         SELECT
          #           1, user.id, 0, dashboard.id, '', 'dark', DATETIME(), DATETIME(), 0
          #         FROM
          #           user
          #         , dashboard
          #         WHERE
          #           USER.login = '${kubernetes_secret.grafana.data.admin-user}'
          #           AND (
          #             dashboard.title = 'FitBod GKE Dash'
          #           )
          #         ON CONFLICT(user_id) DO UPDATE SET
          #            home_dashboard_id = excluded.home_dashboard_id
          #            WHERE user_id = excluded.user_id;"
          #       EOT
          # ]
          # volume_mount {
          #   name       = kubernetes_persistent_volume.grafana_pv.metadata[0].name
          #   mount_path = "/var/lib/grafana"
          # }
        }
        # volume {
        #   name = kubernetes_persistent_volume.grafana_pv.metadata[0].name
        #   persistent_volume_claim {
        #     claim_name = "prometheus-grafana"
        #   }
        # }
        restart_policy = "OnFailure"
      }
    }
  }
}
