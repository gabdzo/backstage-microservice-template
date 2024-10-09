import pulumi
import pulumi_kubernetes as k8s


class KubernetesApp(pulumi.ComponentResource):
    def __init__(
        self,
        name: str,
        namespace: str,
        image: str,
        container_port: int,
        service_port: int,
        replicas: int = 1,
        secret_name: str = None,  # Kubernetes secret name for environment variables
        env_vars: dict = None,  # Environment variables to map from secret
        pvc_name: str = None,  # Optional PVC name for mounting storage
        service_type: str = "ClusterIP",  # Service type for the app
        ingress_annotations: dict = None,  # Ingress annotations for ALB ingress
        ingress_subnets: str = "",  # Subnets for ALB ingress
        ingress_security_groups: str = "",  # Security groups for ALB ingress
        ingress_enabled: bool = False,  # Whether to create ingress for the app
        path: str = "/",  # Ingress path
        secret_provider_class_name: str = "backstage-secrets",  # SecretProviderClass name
        opts: pulumi.ResourceOptions = None,
    ):
        super().__init__("my:k8s:KubernetesApp", name, {}, opts)

        # Step 1: Configure volumes if PVC is provided
        volume_mounts = []
        volumes = []

        # Mount the PVC if provided
        if pvc_name:
            volume_mounts.append(
                k8s.core.v1.VolumeMountArgs(
                    name=f"{name}-volume",
                    mount_path="/mnt/data",
                )
            )
            volumes.append(
                k8s.core.v1.VolumeArgs(
                    name=f"{name}-volume",
                    persistent_volume_claim=k8s.core.v1.PersistentVolumeClaimVolumeSourceArgs(
                        claim_name=pvc_name,
                    ),
                )
            )

        # Step 2: Add the CSI secret store volume
        # This mounts the secret from the SecretProviderClass (CSI Driver)
        volumes.append(
            k8s.core.v1.VolumeArgs(
                name="secrets-store-inline",
                csi=k8s.core.v1.CSIVolumeSourceArgs(
                    driver="secrets-store.csi.k8s.io",
                    read_only=True,
                    volume_attributes={
                        "secretProviderClass": secret_provider_class_name
                    },
                ),
            )
        )

        volume_mounts.append(
            k8s.core.v1.VolumeMountArgs(
                name="secrets-store-inline",
                mount_path="/mnt/secrets-store",  # Adjust the mount path as needed
                read_only=True,
            )
        )

        # Step 3: Add environment variables from the secret if provided
        env = []
        if secret_name and env_vars:
            for env_var, key in env_vars.items():
                env.append(
                    k8s.core.v1.EnvVarArgs(
                        name=env_var,
                        value_from=k8s.core.v1.EnvVarSourceArgs(
                            secret_key_ref=k8s.core.v1.SecretKeySelectorArgs(
                                name=secret_name,
                                key=key,
                            )
                        ),
                    )
                )

        # Step 4: Create the Kubernetes Deployment
        self.deployment = k8s.apps.v1.Deployment(
            f"{name}-deployment",
            metadata=k8s.meta.v1.ObjectMetaArgs(
                namespace=namespace,
                name=name,
                labels={"app": name},
            ),
            spec=k8s.apps.v1.DeploymentSpecArgs(
                replicas=replicas,
                selector=k8s.meta.v1.LabelSelectorArgs(
                    match_labels={"app": name},
                ),
                template=k8s.core.v1.PodTemplateSpecArgs(
                    metadata=k8s.meta.v1.ObjectMetaArgs(labels={"app": name}),
                    spec=k8s.core.v1.PodSpecArgs(
                        service_account_name="backstage",
                        containers=[
                            k8s.core.v1.ContainerArgs(
                                name=name,
                                image=image,
                                ports=[
                                    k8s.core.v1.ContainerPortArgs(
                                        container_port=container_port,
                                    )
                                ],
                                env=env,
                                volume_mounts=volume_mounts,
                            )
                        ],
                        volumes=volumes,
                    ),
                ),
            ),
            opts=pulumi.ResourceOptions(
                parent=self, custom_timeouts=pulumi.CustomTimeouts(create="2m")
            ),
        )

        # Step 5: Create the Kubernetes Service
        self.service = k8s.core.v1.Service(
            f"{name}-service",
            metadata=k8s.meta.v1.ObjectMetaArgs(
                namespace=namespace,
                name=name,
            ),
            spec=k8s.core.v1.ServiceSpecArgs(
                selector={"app": name},
                ports=[
                    k8s.core.v1.ServicePortArgs(
                        port=service_port,
                        target_port=container_port,
                    )
                ],
                type=service_type,  # ClusterIP, LoadBalancer, etc.
            ),
            opts=pulumi.ResourceOptions(
                parent=self, custom_timeouts=pulumi.CustomTimeouts(create="2m")
            ),
        )

        # Step 6: Optionally create an Ingress
        if ingress_enabled:
            ingress_annotations = ingress_annotations or {}
            ingress_annotations.update(
                {
                    "alb.ingress.kubernetes.io/subnets": ingress_subnets,
                    "alb.ingress.kubernetes.io/security-groups": ingress_security_groups,
                }
            )
            self.ingress = k8s.networking.v1.Ingress(
                f"{name}-ingress",
                metadata=k8s.meta.v1.ObjectMetaArgs(
                    namespace=namespace,
                    name=f"{name}-ingress",
                    annotations=ingress_annotations,
                ),
                spec=k8s.networking.v1.IngressSpecArgs(
                    rules=[
                        k8s.networking.v1.IngressRuleArgs(
                            http=k8s.networking.v1.HTTPIngressRuleValueArgs(
                                paths=[
                                    k8s.networking.v1.HTTPIngressPathArgs(
                                        path=path,
                                        path_type="Prefix",
                                        backend=k8s.networking.v1.IngressBackendArgs(
                                            service=k8s.networking.v1.IngressServiceBackendArgs(
                                                name=self.service.metadata.name,
                                                port=k8s.networking.v1.ServiceBackendPortArgs(
                                                    number=80,
                                                ),
                                            ),
                                        ),
                                    )
                                ]
                            )
                        )
                    ],
                ),
                opts=pulumi.ResourceOptions(
                    parent=self, custom_timeouts=pulumi.CustomTimeouts(create="2m")
                ),
            )

        self.register_outputs({})
