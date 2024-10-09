"""An AWS Python Pulumi program"""

import pulumi
import pulumi_kubernetes as k8s
import pulumi_aws as aws

from eks.app import KubernetesApp
from eks.charts import HelmChart
from eks.ssm_provider import SecretProviderClass
from eks.storage import Storage

from aws.endpoint import VpcEndpoint

from pulumi_aws import s3

# # Create an AWS resource (S3 Bucket)
# bucket = s3.BucketV2('my-bucket')

# # Export the name of the bucket
# pulumi.export('bucket_name', bucket.id)

k8s_provider = k8s.Provider(
    "k8s-provider",
    kubeconfig="~/.kube/config",
    enable_server_side_apply=True,
)

# Define the VPC ID where the endpoint will be created
vpc_id = "vpc-09f7ceeec4b4efae8"  # Replace with your actual VPC ID
region = "eu-central-1"  # Replace with your desired AWS region

subnets = ['subnet-05ffa3afa88e7ded8', 'subnet-02cf3aa9d99c969ce', 'subnet-0e0a889c6524d0ece']

security_group_ids = ['sg-002447b7c4baf4a76', 'sg-09c3c51612f017b55', 'sg-0ef9f67f19388dc13', 'sg-0c52fed7668de83fb']

# Create the VPC Endpoint for STS
sts_endpoint = VpcEndpoint(
    name="sts-vpc-endpoint",
    vpc_id=vpc_id,
    region=region,
    subnet_ids=subnets,
    security_group_ids=security_group_ids,
    opts=pulumi.ResourceOptions(),
)




namespace = k8s.core.v1.Namespace(
    "backstage",
    metadata=k8s.meta.v1.ObjectMetaArgs(
        name="backstage",
    ),
    opts=pulumi.ResourceOptions(provider=k8s_provider),
)

service_account = k8s.core.v1.ServiceAccount(
    "backstage",
    metadata=k8s.meta.v1.ObjectMetaArgs(
        name="backstage",
        namespace="backstage",
        annotations={
            "eks.amazonaws.com/role-arn": "arn:aws:iam::005669471820:role/deployment-role",
        },
    ),
    opts=pulumi.ResourceOptions(
        provider=k8s_provider,
        depends_on=[namespace],
    ),
)


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

# Step 1: Create Storage for PostgreSQL (optional)
postgres_storage = Storage(
    name="postgres",
    namespace="backstage",
    storage_size="2Gi",
    host_path="/mnt/data",  # Path for Persistent Volume (PV)
    opts=pulumi.ResourceOptions(provider=k8s_provider),
)

# Step 2: Deploy PostgreSQL with Storage
postgres_app = KubernetesApp(
    name="postgres",
    namespace="backstage",
    image="postgres:latest",
    container_port=5432,
    replicas=1,
    pvc_name=postgres_storage.pvc.metadata.name,  # Use the PVC from the storage class
    secret_name="backstage-secrets", 
    secret_provider_class_name="backstage-secrets", # Secret for environment variables
    env_vars={
        "POSTGRES_USER": "POSTGRES_USER",
        "POSTGRES_PASSWORD": "POSTGRES_PASSWORD",
    },
    service_type="ClusterIP",
    opts=pulumi.ResourceOptions(provider=k8s_provider, depends_on=[postgres_storage]),
)

# Step 3: Deploy Backstage App with Ingress
backstage_app = KubernetesApp(
    name="backstage",
    namespace="backstage",
    image=pulumi.Config().require("backstage_image"),
    container_port=7007,
    replicas=1,
    secret_name="backstage-secrets",  # Secret for environment variables
    secret_provider_class_name="backstage-secrets", # Secret for environment variables
    env_vars={
        "GH_CLIENT_ID": "GH_CLIENT_ID",
        "GH_CLIENT_SECRET": "GH_CLIENT_SECRET",
        "GH_TOKEN": "GH_TOKEN",
        "POSTGRES_USER": "POSTGRES_USER",
        "POSTGRES_PASSWORD": "POSTGRES_PASSWORD",
    },
    ingress_enabled=True,
    ingress_annotations={
        "alb.ingress.kubernetes.io/scheme": "internet-facing",
        "alb.ingress.kubernetes.io/target-type": "ip",
        "alb.ingress.kubernetes.io/load-balancer-name": "backstage",
        "alb.ingress.kubernetes.io/healthcheck-path": "/",
        "alb.ingress.kubernetes.io/healthcheck-port": "80",
        "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP",
        "alb.ingress.kubernetes.io/healthcheck-interval-seconds": "30",
        "alb.ingress.kubernetes.io/healthcheck-timeout-seconds": "5",
        "alb.ingress.kubernetes.io/healthy-threshold-count": "2",
        "alb.ingress.kubernetes.io/unhealthy-threshold-count": "2",
    },
    ingress_subnets="subnet-07e2f5900b2796fc2,subnet-01d939942e8209cfc",
    ingress_security_groups="sg-0f365b919964bde9d,sg-0e70ed1b30427eee3",
    service_type="ClusterIP",
    opts=pulumi.ResourceOptions(provider=k8s_provider),
)
