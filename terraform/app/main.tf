

resource "kubernetes_deployment" "backstage" {
  metadata {
    name      = "backstage"
    namespace = var.namespace
    labels = {
      app = "backstage"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backstage"
      }
    }

    template {
      metadata {
        labels = {
          app = "backstage"
        }
      }

      spec {
        serviceAccountName = "my-service-account"
        containers {
          name  = "backstage"
          image = "backstage:latest"

          env {
            name = "GH_CLIENT_ID"
            valueFrom {
              secretKeyRef {
                name = "backstage-secrets"
                key  = "GH_CLIENT_ID"
              }
            }
          }

          env {
            name = "GH_CLIENT_SECRET"
            valueFrom {
              secretKeyRef {
                name = "backstage-secrets"
                key  = "GH_CLIENT_SECRET"
              }
            }
          }

          env {
            name = "GH_TOKEN"
            valueFrom {
              secretKeyRef {
                name = "backstage-secrets"
                key  = "GH_TOKEN"
              }
            }
          }

          ports {
            container_port = 7007
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 7007
            }
            initial_delay_seconds = 30
            period_seconds        = 10
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

resource "kubernetes_service" "backstage" {
  metadata {
    name      = "backstage"
    namespace = "backstage"
  }

  spec {
    selector = {
      app = "backstage"
    }

    port {
      name       = "http"
      port       = 80
      target_port = "http"
    }
  }
}


