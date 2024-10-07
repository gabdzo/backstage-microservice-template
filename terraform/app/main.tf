
resource "kubernetes_manifest" "backstage_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "backstage"
      namespace = var.namespace
      labels = {
        app = "backstage"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "backstage"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "backstage"
          }
        }
        spec = {
          serviceAccountName = "backstage"
          containers = [
            {
              name  = "backstage"
              image = "backstage:latest"
              imagePullPolicy = "Always"
              env = [
                {
                  name = "GH_CLIENT_ID"
                  valueFrom = {
                    secretKeyRef = {
                      name = "backstage-secrets"
                      key  = "GH_CLIENT_ID"
                    }
                  }
                },
                {
                  name = "GH_CLIENT_SECRET"
                  valueFrom = {
                    secretKeyRef = {
                      name = "backstage-secrets"
                      key  = "GH_CLIENT_SECRET"
                    }
                  }
                },
                {
                  name = "GH_TOKEN"
                  valueFrom = {
                    secretKeyRef = {
                      name = "backstage-secrets"
                      key  = "GH_TOKEN"
                    }
                  }
                }
              ]
              ports = [
                {
                  containerPort = 7007
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
                  secretProviderClass = "ssm-parameter-store"
                }
              }
            }
          ]
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


