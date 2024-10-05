resource "kubernetes_secret" "backstage_secrets" {
  metadata {
    name      = "backstage-secrets"
    namespace = "backstage"
  }

  data = {
    GITHUB_TOKEN = "VG9rZW5Ub2tlblRva2VuVG9rZW5NYWxrb3ZpY2hUb2tlbg=="
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "backstage" {
  metadata {
    name      = "backstage"
    namespace = "backstage"
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
        container {
          name  = "backstage"
          image = "backstage:latest"

          port {
            container_port = 7007
          }

          liveness_probe {
            http_get {
              path = "/healthcheck"
              port = 7007
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

          readiness_probe {
            http_get {
              path = "/healthcheck"
              port = 7007
            }

            initial_delay_seconds = 3
            period_seconds        = 3
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