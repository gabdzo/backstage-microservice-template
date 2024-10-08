resource "kubernetes_namespace" "backstage" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "secrets-store-csi-driver" {
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.4.5"
  namespace  = "kube-system"
  timeout    = 10 * 60

  values = [
    <<VALUES
    syncSecret:
      enabled: true   # Install RBAC roles and bindings required for K8S Secrets syncing if true (default: false)
VALUES
  ]
}


resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "backstage-secrets"
      namespace = "backstage"
    }
    spec = {
      provider   = "aws"
      parameters = {
        objects = <<EOF
        - objectName: "/backstage-showcase/GH_CLIENT_ID"
          objectType: "ssmparameter"
          objectAlias: "GH_CLIENT_ID"
        - objectName: "/backstage-showcase/GH_CLIENT_SECRET"
          objectType: "ssmparameter"
          objectAlias: "GH_CLIENT_SECRET"
        - objectName: "/backstage-showcase/GH_TOKEN"
          objectType: "ssmparameter"
          objectAlias: "GH_TOKEN"
        - objectName: "/backstage-showcase/POSTGRES_PASSWORD"
          objectType: "ssmparameter"
          objectAlias: "POSTGRES_PASSWORD"
        - objectName: "/backstage-showcase/POSTGRES_USER"
          objectType: "ssmparameter"
          objectAlias: "POSTGRES_USER"
        EOF
      }
      secretObjects = [
        {
          secretName = "backstage-secrets"
          type       = "Opaque"
          data = [
            {
              objectName = "GH_CLIENT_ID"
              key        = "GH_CLIENT_ID"
            },
            {
              objectName = "GH_CLIENT_SECRET"
              key        = "GH_CLIENT_SECRET"
            },
            {
              objectName = "GH_TOKEN"
              key        = "GH_TOKEN"
            },
            {
              objectName = "POSTGRES_PASSWORD"
              key        = "POSTGRES_PASSWORD"
            },
            {
              objectName = "POSTGRES_USER"
              key        = "POSTGRES_USER"
            }
          ]
        }
      ]
    }
  }
}

# resource "kubernetes_service_account" "backstage" {
#   metadata {
#     name      = "backstage"
#     namespace = var.namespace
#     annotations = {
#       "eks.amazonaws.com/role-arn" = var.deployment_role
#     }
#   }

#   depends_on = [kubernetes_namespace.backstage]
# }

# resource "kubernetes_secret" "backstage" {
#   metadata {
#     annotations = {
#       "kubernetes.io/service-account.name" = "backstage"
#     }

#     generate_name = "backstage-"
#   }

#   type                           = "kubernetes.io/service-account-token"
#   depends_on                     = [kubernetes_namespace.backstage]
# #   wait_for_service_account_token = true
# }