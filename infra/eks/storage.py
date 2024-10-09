import pulumi
import pulumi_kubernetes as k8s

class Storage(pulumi.ComponentResource):
    def __init__(
        self,
        name: str,
        namespace: str,
        storage_size: str = "2Gi",  # Persistent storage size
        host_path: str = "/mnt/data",  # Local path for PV
        opts: pulumi.ResourceOptions = None,
    ):
        super().__init__('my:k8s:Storage', name, {}, opts)

        # Step 1: Create Persistent Volume (PV)
        self.pv = k8s.core.v1.PersistentVolume(
            f"{name}-pv",
            metadata=k8s.meta.v1.ObjectMetaArgs(
                name=f"{name}-storage",
                labels={"type": "local"},
            ),
            spec=k8s.core.v1.PersistentVolumeSpecArgs(
                storage_class_name="manual",
                capacity={"storage": storage_size},
                access_modes=["ReadWriteOnce"],
                persistent_volume_reclaim_policy="Retain",
                host_path=k8s.core.v1.HostPathVolumeSourceArgs(
                    path=host_path,
                ),
            ),
            opts=pulumi.ResourceOptions(parent=self),
        )

        # Step 2: Create Persistent Volume Claim (PVC)
        self.pvc = k8s.core.v1.PersistentVolumeClaim(
            f"{name}-pvc",
            metadata=k8s.meta.v1.ObjectMetaArgs(
                namespace=namespace,
                name=f"{name}-storage-claim",
            ),
            spec=k8s.core.v1.PersistentVolumeClaimSpecArgs(
                storage_class_name="manual",
                access_modes=["ReadWriteOnce"],
                resources=k8s.core.v1.ResourceRequirementsArgs(
                    requests={"storage": storage_size},
                ),
            ),
            opts=pulumi.ResourceOptions(parent=self),
        )

        self.register_outputs({
            "pv_name": self.pv.metadata.name,
            "pvc_name": self.pvc.metadata.name
        })
