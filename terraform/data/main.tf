resource "kubernetes_namespace" "backstage" {
  metadata {
    name = var.namespace
  }
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
    namespace = var.namespace
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
        serviceAccountName = "my-service-account"
        containers {
          name  = "postgres"
          image = "postgres:latest"

          env {
            name = "POSTGRES_USER"
            valueFrom {
              secretKeyRef {
                name = "backstage-secrets"
                key  = "username"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            valueFrom {
              secretKeyRef {
                name = "backstage-secrets"
                key  = "password"
              }
            }
          }

          ports {
            container_port = 5432
          }

          volumeMounts {
            name      = "secrets-store-inline"
            mountPath = "/mnt/secrets-store"
            readOnly  = true
          }
        }

        volumes {
          name = "secrets-store-inline"
          csi {
            driver            = "secrets-store.csi.k8s.io"
            readOnly          = true
            volumeAttributes = {
              secretProviderClass = "ssm-parameter-store"
            }
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