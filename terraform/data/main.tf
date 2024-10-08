
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
resource "kubernetes_manifest" "postgres_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "postgres"
      namespace = var.namespace
      labels = {
        app = "postgres"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "postgres"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "postgres"
          }
        }
        spec = {
          serviceAccountName = "backstage"
          containers = [
            {
              name  = "postgres"
              image = "postgres:latest"
              imagePullPolicy = "Always"
              env = [
                {
                  name = "POSTGRES_USER"
                  valueFrom = {
                    secretKeyRef = {
                      name = "backstage-secrets"
                      key  = "POSTGRES_USER"
                    }
                  }
                },
                {
                  name = "POSTGRES_PASSWORD"
                  valueFrom = {
                    secretKeyRef = {
                      name = "backstage-secrets"
                      key  = "POSTGRES_PASSWORD"
                    }
                  }
                }
              ]
              ports = [
                {
                  containerPort = 5432
                }
              ]
              volumeMounts = [
                {
                  name      = "secrets-store-inline"
                  mountPath = "/mnt/secrets-store"
                  readOnly  = true
                }
              ]
            }
          ]
          volumes = [
            {
              name = "secrets-store-inline"
              csi = {
                driver            = "secrets-store.csi.k8s.io"
                readOnly          = true
                volumeAttributes = {
                  secretProviderClass = "backstage-secrets"
                }
              }
            }
          ]
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