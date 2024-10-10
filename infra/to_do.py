### Just keep this here if we want to switch fully to pulumi in the future

# # Install Secrets Store CSI Driver with Helm
# secrets_store_csi_driver = HelmChart(
#     name="secrets-store-csi-driver",
#     chart="secrets-store-csi-driver",
#     version="1.4.5",  # Replace with the version you need
#     repo="https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts",
#     namespace="backstage",
#     values={
#         "syncSecret": {
#             "enabled": True,  # Enable K8s Secret syncing
#         }
#     },
#     opts=pulumi.ResourceOptions(
#         provider=k8s_provider,
#         depends_on=[namespace, sts_endpoint],
#     ),
# )

# # Install AWS Load Balancer Controller with Helm
# aws_load_balancer_controller = HelmChart(
#     name="aws-load-balancer-controller",
#     chart="aws-load-balancer-controller",
#     version="1.9.0",  # Replace with your desired version
#     repo="https://aws.github.io/eks-charts",
#     namespace="backstage",
#     values={"replicaCount": 1},
#     set_values={
#         "clusterName": "showcase",  # Replace with your cluster name
#         "serviceAccount.create": False,
#         "serviceAccount.name": "backstage",
#     },
#     opts=pulumi.ResourceOptions(
#         provider=k8s_provider,
#         depends_on=[namespace, sts_endpoint],
#     ),
# )

# # Define secret names
# secret_names = [
#     "GH_CLIENT_ID",
#     "GH_CLIENT_SECRET",
#     "GH_TOKEN",
#     "POSTGRES_PASSWORD",
#     "POSTGRES_USER",
# ]

# # Define the prefix for the SSM parameters
# ssm_store_prefix = "/backstage-showcase"

# # Create the SecretProviderClass in Pulumi
# secret_provider_class = SecretProviderClass(
#     name="backstage-secrets",
#     namespace="backstage",
#     provider="aws",
#     ssm_store_prefix=ssm_store_prefix,
#     secret_names=secret_names,
#     opts=pulumi.ResourceOptions(
#         provider=k8s_provider,
#         depends_on=[namespace, secrets_store_csi_driver],
#     ),
# )


# def create_secret_provider_class(ssm_prefix: str, secret_names: list, namespace: str = "backstage", depends_on=None):
#     # Dynamically build the objects section from the secret names
#     objects = "\n".join([
#         f"- objectName: \"{ssm_prefix}/{secret_name}\"\n  objectType: \"ssmparameter\"\n  objectAlias: \"{secret_name}\""
#         for secret_name in secret_names
#     ])

#     # Dynamically build the secretObjects section
#     secret_objects = [{"objectName": secret_name, "key": secret_name} for secret_name in secret_names]

#     # Define the SecretProviderClass Custom Resource
#     secret_provider_class = k8s.apiextensions.CustomResource(
#         "backstage-secrets",
#         api_version="secrets-store.csi.x-k8s.io/v1",
#         kind="SecretProviderClass",
#         metadata={
#             "name": "backstage-secrets",
#             "namespace": namespace,
#         },
#         spec={
#             "provider": "aws",
#             "parameters": {
#                 "objects": objects
#             },
#             "secretObjects": [
#                 {
#                     "secretName": "my-secret",
#                     "type": "Opaque",
#                     "data": secret_objects
#                 }
#             ]
#         },
#         opts=pulumi.ResourceOptions(depends_on=depends_on)
#     )

#     # Export the name of the created SecretProviderClass
#     pulumi.export("secret_provider_class_name", secret_provider_class.metadata["name"])

# # Example usage
# ssm_prefix = "/backstage-showcase"
# secret_names = [
#     "GH_CLIENT_ID",
#     "GH_CLIENT_SECRET",
#     "GH_TOKEN",
#     "POSTGRES_PASSWORD",
#     "POSTGRES_USER"
# ]

# Assuming you have a resource like Helm chart or other dependencies
# e.g., csi_driver_installation = HelmChart(...)
# create_secret_provider_class should wait for the csi_driver_installation to finish.

# # Create the SecretProviderClass with dependency on another resource
# create_secret_provider_class(ssm_prefix, secret_names, namespace="backstage", depends_on=[secret_provider_class])