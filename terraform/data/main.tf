resource "kubernetes_namespace" "backstage" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "postgres-secrets"
    namespace = var.namespace
  }

  data = {
    username = "admin"
    password = "P4ssw0rd"
  }

  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_persistent_volume" "postgres_storage" {
  metadata {
    name = "postgres-storage"
    labels = {
      type = "local"
    }
  }

  spec {
    storage_class_name = "manual"
    capacity = {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_storage_claim" {
  metadata {
    name      = "postgres-storage-claim"
    namespace = "backstage"
  }

  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = "backstage"
    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:latest"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_DB"
            value = "mydatabase"
          }

          env {
            name  = "POSTGRES_USER"
            value = "myuser"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "mypassword"
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        volume {
          name = "postgres-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_storage_claim.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = "backstage"
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port = 5432
    }
  }
}