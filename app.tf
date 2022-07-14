data "local_file" "masterkey" {
  filename = var.app_master_key_file != "" ? var.app_master_key_file : "${path.root}/config/secrets/master.key"
}

resource "random_password" "app_pass" {
  for_each         = var.app_user_pass
  length           = 16
  special          = true
  override_special = "_!%"
}

# Store 'admin/user1' in k8s secret. Generate a random password for each user if not set.
resource "kubernetes_secret" "app_secret" {
  for_each = var.app_user_pass
  metadata {
    name = "app-pass-${each.key}"
  }
  data = {
    "login" = "${each.value.email}:${each.value.password == "" || each.value.password == null ? random_password.app_pass[each.key].result : each.value.password}"
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "config" {

  metadata {
    name = "${var.app_name}-config"
  }
  depends_on = [module.db]

  data = {
    RAILS_MASTER_KEY                   = trimspace(data.local_file.masterkey.content)
    PORT                               = "3000"
    DISABLE_DATABASE_ENVIRONMENT_CHECK = ""
    RAILS_LOG_TO_STDOUT                = "true"
    POSTGRES_USER                      = var.db_user
    POSTGRES_HOST                      = module.db.private_ip_address
    POSTGRES_PW                        = module.db.generated_user_password
    PGPASSWORD                         = module.db.generated_user_password
  }
}
resource "kubernetes_job" "init_app" {
  count      = 1
  depends_on = [kubernetes_config_map.config, kubernetes_secret.app_secret, google_compute_disk.app]
  timeouts {
    create = "3m"
    delete = "2m"
  }
  metadata {
    name = "${var.app_name}-init"
    labels = {
      app = var.app_name
    }
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          image             = var.app_image_name
          image_pull_policy = "IfNotPresent"
          name              = "${var.app_name}-init"
          command           = ["/bin/bash", "-c"]
          args = [<<EOT
                  bundle exec rake assets:precompile
                  # This is a very rudimentary way to check if records are already in the database.
                  bundle exec rake db:create
                  count=$(psql -U "$POSTGRES_USER" -d my_workout_production -h "$POSTGRES_HOST" -AXqtc "SELECT reltuples AS estimate FROM pg_class where relname ='single_sets'")
                  if [[ "$count" -eq 0 ]]; then
                          bundle exec rake db:migrate db:seed
                  elif [[ -z "$count" ]]; then
                          bundle exec rake db:create db:migrate db:seed
                  else
                          bundle exec rake db:migrate
                  fi
                  readarray -td: ADMIN < <(printf '%s' "$admin")
                  readarray -td: USER1 < <(printf '%s' "$user1")
                  bundle exec rails runner "AdminUser.find_by_email('$${ADMIN[0]}').update_attributes(:password => '$${ADMIN[1]}')"
                  bundle exec rails runner "User.find_by_email('$${USER1[0]}').update_attributes(:password => '$${USER1[1]}')"
                EOT
          ]
          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }
          dynamic "env" {
            for_each = var.app_user_pass
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "app-pass-${env.key}"
                  key  = "login"
                }
              }
            }
          }
          volume_mount {
            name       = kubernetes_persistent_volume.app_pv.metadata[0].name
            mount_path = "/app/public/assets"
          }
        }
        volume {
          name = kubernetes_persistent_volume.app_pv.metadata[0].name
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.app_pvc.metadata[0].name
          }
        }
        restart_policy = "Never"
      }
    }
  }
}


resource "kubernetes_deployment" "app" {
  depends_on = [kubernetes_config_map.config, kubernetes_secret.app_secret, kubernetes_job.init_app]
  timeouts {
    create = "2m"
    delete = "2m"
  }
  metadata {
    name = var.app_name
    labels = {
      app = var.app_name
    }
  }
  spec {
    # replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }
    template {
      metadata {
        name = var.app_name
        labels = {
          app = var.app_name
        }
      }
      spec {
        container {
          image             = var.app_image_name
          image_pull_policy = "IfNotPresent"
          name              = var.app_name
          command           = ["/bin/bash", "-c", "bundle exec rails s -b 0.0.0.0 -p 3001"]
          port {
            container_port = 3001
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }
          resources {
            limits = {
              cpu    = "250m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "150m"
              memory = "128Mi"
            }
          }
          volume_mount {
            name       = kubernetes_persistent_volume.app_pv.metadata[0].name
            mount_path = "/app/public/assets"
          }
        }
        volume {
          name = kubernetes_persistent_volume.app_pv.metadata[0].name
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.app_pvc.metadata[0].name
          }
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "app_frontend" {
  metadata {
    name = "app-frontend"
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.spec[0].template[0].metadata[0].labels.app
    }
    type = "NodePort"
    port {
      port        = 3001
      target_port = 3001
    }
  }
}
