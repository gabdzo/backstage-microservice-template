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

subnets = [
    "subnet-05ffa3afa88e7ded8",
    "subnet-02cf3aa9d99c969ce",
    "subnet-0e0a889c6524d0ece",
]

security_group_ids = [
    "sg-002447b7c4baf4a76",
    "sg-09c3c51612f017b55",
    "sg-0ef9f67f19388dc13",
    "sg-0c52fed7668de83fb",
]

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
    service_port=5432,
    replicas=1,
    pvc_name=postgres_storage.pvc.metadata.name,  # Use the PVC from the storage class
    secret_name="backstage-secrets",
    secret_provider_class_name="backstage-secrets",  # Secret for environment variables
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
    service_port=80,
    replicas=1,
    secret_name="backstage-secrets",  # Secret for environment variables
    secret_provider_class_name="backstage-secrets",  # Secret for environment variables
    env_vars={
        "GH_CLIENT_ID": "GH_CLIENT_ID",
        "GH_CLIENT_SECRET": "GH_CLIENT_SECRET",
        "GH_TOKEN": "GH_TOKEN",
        "POSTGRES_USER": "POSTGRES_USER",
        "POSTGRES_PASSWORD": "POSTGRES_PASSWORD",
    },
    # ingress_enabled=True,
    # ingress_annotations={
    #     "alb.ingress.kubernetes.io/scheme": "internet-facing",
    #     "alb.ingress.kubernetes.io/target-type": "ip",
    #     "alb.ingress.kubernetes.io/load-balancer-name": "backstage",
    #     "alb.ingress.kubernetes.io/healthcheck-path": "/",
    #     "alb.ingress.kubernetes.io/healthcheck-port": "80",
    #     "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP",
    #     "alb.ingress.kubernetes.io/healthcheck-interval-seconds": "30",
    #     "alb.ingress.kubernetes.io/healthcheck-timeout-seconds": "5",
    #     "alb.ingress.kubernetes.io/healthy-threshold-count": "2",
    #     "alb.ingress.kubernetes.io/unhealthy-threshold-count": "2",
    # },
    # ingress_subnets="subnet-07e2f5900b2796fc2,subnet-01d939942e8209cfc",
    # ingress_security_groups="sg-0f365b919964bde9d,sg-0e70ed1b30427eee3",
    service_type="ClusterIP",
    opts=pulumi.ResourceOptions(provider=k8s_provider),
)
