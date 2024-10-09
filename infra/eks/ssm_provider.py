import pulumi
import pulumi_kubernetes as k8s


class SecretProviderClass(pulumi.ComponentResource):
    def __init__(
        self,
        name: str,
        namespace: str,
        provider: str,
        ssm_store_prefix: str,
        secret_names: list,  # List of secret names like ["GH_CLIENT_ID", "GH_CLIENT_SECRET", ...]
        opts: pulumi.ResourceOptions = None,
    ):
        super().__init__("my:k8s:SecretProviderClass", name, {}, opts)

        # Build the objects list dynamically using the secret_names and ssm_store_prefix
        objects = [
            {
                "objectName": f"{ssm_store_prefix}/{secret_name}",
                "objectType": "ssmparameter",
                "objectAlias": secret_name,
            }
            for secret_name in secret_names
        ]

        # Convert objects list to string format for the manifest
        objects_string = "\n".join(
            [
                f"- objectName: \"{obj['objectName']}\"\n  objectType: \"{obj['objectType']}\"\n  objectAlias: \"{obj['objectAlias']}\""
                for obj in objects
            ]
        )

        # Build the secretObjects list dynamically using the secret_names
        secret_objects = [
            {"objectName": secret_name, "key": secret_name}
            for secret_name in secret_names
        ]

        # Create the SecretProviderClass custom resource
        self.secret_provider_class = k8s.apiextensions.CustomResource(
            name,
            api_version="secrets-store.csi.x-k8s.io/v1",
            kind="SecretProviderClass",
            metadata={
                "name": name,
                "namespace": namespace,
            },
            spec={
                "provider": provider,
                "parameters": {"objects": objects_string},
                "secretObjects": [
                    {"secretName": name, "type": "Opaque", "data": secret_objects}
                ],
            },
            opts=pulumi.ResourceOptions(parent=self),
        )

        self.register_outputs({})
