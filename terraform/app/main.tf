
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
              image = var.backstage_image
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
                },
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

resource "kubernetes_service" "backstage" {
  metadata {
    name      = "backstage"
    namespace = "backstage"
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "backstage"
    }

    port {
      name       = "http"
      port       = 80
      target_port = 7007
    }
  }
}


resource "kubernetes_manifest" "backstage" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name        = "backstage"
      namespace   = "backstage"
      annotations = {
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"        = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "backstage"
        "alb.ingress.kubernetes.io/subnets"            = "subnet-07e2f5900b2796fc2,subnet-01d939942e8209cfc"
        "alb.ingress.kubernetes.io/security-groups"    = "sg-0f365b919964bde9d,sg-0e70ed1b30427eee3,sg-080384f53c011150d,sg-0c6b0df340dc31a65,sg-077b97247a9c2ade5,sg-0f1c0ce87792e7f43"

        "alb.ingress.kubernetes.io/target-group-attributes" = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=60"
        "alb.ingress.kubernetes.io/group.name"         = "backstage-tg-showcase"
        "alb.ingress.kubernetes.io/healthcheck-path"   = "/"  # Replace with your health check path
        "alb.ingress.kubernetes.io/healthcheck-port"   = "80"
        "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
        "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "30"
        "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = "5"
        "alb.ingress.kubernetes.io/healthy-threshold-count" = "2"
        "alb.ingress.kubernetes.io/unhealthy-threshold-count" = "2"
      }
    }
    spec = {
      ingressClassName = "alb"
      rules = [
        {
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "backstage"
                    port = {
                      number = 80
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}