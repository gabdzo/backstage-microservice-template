import pulumi
import pulumi_kubernetes as k8s
from pulumi_kubernetes.apps.v1 import Deployment, DeploymentSpecArgs
from pulumi_kubernetes.core.v1 import (
    Service, ServiceSpecArgs, Container, ContainerPort,
    Volume, VolumeMount, EnvVar, EnvVarSource, SecretKeySelector
)
from pulumi_kubernetes.meta.v1 import ObjectMeta, LabelSelector
from pulumi_kubernetes.networking.v1 import Ingress, IngressSpec, IngressRule
from dataclasses import dataclass
from typing import Optional, Dict, List
import re

@dataclass
class IngressConfig:
    enabled: bool = False
    annotations: Optional[Dict[str, str]] = None
    subnets: str = ""
    security_groups: str = ""
    path: str = "/"

@dataclass
class ServiceConfig:
    port: int
    container_port: int
    type: str = "ClusterIP"

class KubernetesAppError(Exception):
    """Base exception for KubernetesApp errors."""
    pass

class KubernetesApp(pulumi.ComponentResource):
    """
    KubernetesApp creates a complete Kubernetes application stack including
    Deployment, Service, and optionally Ingress.
    
    Args:
        name: The name of the application
        namespace: Kubernetes namespace
        image: Docker image to deploy
        service_config: Service configuration
        ingress_config: Optional ingress configuration
        replicas: Number of pod replicas
        secret_name: Name of the Kubernetes secret for environment variables
        env_vars: Dictionary of environment variables to map from secret
        pvc_name: Optional PVC name for mounting storage
    """
    def __init__(
        self,
        name: str,
        namespace: str,
        image: str,
        service_config: ServiceConfig,
        ingress_config: Optional[IngressConfig] = None,
        ...
    ):
        self._validate_inputs(name, namespace, image)
        super().__init__("my:k8s:KubernetesApp", name, {}, opts)

        self.labels = {"app": name}
        self.name = name
        self.namespace = namespace
        
        # Create resources
        self.deployment = self._create_deployment(image, service_config.container_port, env_vars, secret_name, pvc_name)
        self.service = self._create_service(service_config.port, service_config.container_port, service_config.type)
        
        if ingress_config:
            self.ingress = self._create_ingress(ingress_config.path, ingress_config.annotations, ingress_config.subnets, ingress_config.security_groups)
        
        self.register_outputs({})

    @staticmethod
    def _validate_inputs(name: str, namespace: str, image: str) -> None:
        """Validate input parameters."""
        if not re.match(r'^[a-z0-9]([-a-z0-9]*[a-z0-9])?$', name):
            raise KubernetesAppError(f"Invalid name format: {name}")
        
        if not re.match(r'^[a-z0-9]([-a-z0-9]*[a-z0-9])?$', namespace):
            raise KubernetesAppError(f"Invalid namespace format: {namespace}")
        
        if not image:
            raise KubernetesAppError("Image cannot be empty")

    def _create_volumes(self, pvc_name: str = None) -> tuple[list, list]:
        """Create volume and volume mount configurations."""
        volume_mounts = []
        volumes = []
        
        if pvc_name:
            volume_mounts.append(VolumeMount(
                name=f"{self.name}-volume",
                mount_path="/mnt/data",
            ))
            volumes.append(Volume(
                name=f"{self.name}-volume",
                persistent_volume_claim={"claimName": pvc_name},
            ))
        
        volumes.append(self._create_csi_volume())
        return volume_mounts, volumes

    def _create_csi_volume(self) -> Volume:
        """Create CSI secret store volume."""
        return Volume(
            name="secrets-store-inline",
            csi={
                "driver": "secrets-store.csi.k8s.io",
                "readOnly": True,
                "volumeAttributes": {
                    "secretProviderClass": self.secret_provider_class_name
                },
            },
        )

    def _create_deployment(self, image: str, container_port: int, ...) -> Deployment:
        """Create Kubernetes Deployment."""
        volume_mounts, volumes = self._create_volumes(pvc_name)
        env = self._create_env_vars(env_vars, secret_name)
        
        return Deployment(
            f"{self.name}-deployment",
            metadata=self._create_metadata(),
            spec=DeploymentSpecArgs(
                replicas=replicas,
                selector=LabelSelector(match_labels=self.labels),
                template=self._create_pod_template(image, container_port, env, volume_mounts, volumes),
            ),
            opts=self._create_resource_options(),
        )

    def _create_pod_template(self, image: str, container_port: int, env: list, volume_mounts: list, volumes: list) -> dict:
        """Create pod template configuration."""
        return {
            "metadata": {"labels": self.labels},
            "spec": {
                "serviceAccountName": "backstage",
                "containers": [{
                    "name": self.name,
                    "image": image,
                    "ports": [{"containerPort": container_port}],
                    "env": env,
                    "volumeMounts": volume_mounts,
                }],
                "volumes": volumes,
            },
        }

    def _create_metadata(self, suffix: str = "") -> ObjectMeta:
        """Create metadata for Kubernetes resources."""
        name = f"{self.name}{suffix}"
        return ObjectMeta(
            namespace=self.namespace,
            name=name,
            labels=self.labels,
        )

    def _create_resource_options(self) -> pulumi.ResourceOptions:
        """Create standard resource options."""
        return pulumi.ResourceOptions(
            parent=self, 
            custom_timeouts=pulumi.CustomTimeouts(create="2m")
        )
