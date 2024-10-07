module csi-driver {
  source  = "terraform-module/release/helm"
  version = "2.6.0"

  namespace  = var.namespace
  repository =  "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"

  app = {
    name          = "secrets-store-csi-driver"
    version       = "1.4.5"
    chart         = "secrets-store-csi-driver"
    description   = "A Helm chart to install the Secrets Store CSI Driver and the AWS Key Management Service Provider inside a Kubernetes cluster."
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }
  values = []

  set = [
    {
      name  = "labels.kubernetes\\.io/name"
      value = "secrets-store-csi-driver"
    },
    {
      name  = "service.labels.kubernetes\\.io/name"
      value = "secrets-store-csi-driver"
    },
  ]

#   set_sensitive = [
#     {
#       path  = "master.adminUser"
#       value = "jenkins"
#     },
#   ]
}

resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "ssm-parameter-store"
      namespace = "backstage"
    }
    spec = {
      provider   = "aws"
      parameters = {
        objects = <<EOF
        - objectName: "/backstage-showcase/"
          objectType: "ssmparameter"
          objectAlias: "backstage-secrets"
          jmesPath:
            - path: "Parameters[*].Name"
              objectAlias: "name"
            - path: "Parameters[*].Value"
              objectAlias: "value"
        EOF
      }
    }
  }
}

resource "kubernetes_service_account" "backstage" {
  metadata {
    name      = "backstage"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.deployment_role
    }
  }
}