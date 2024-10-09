import pulumi
import pulumi_aws as aws


class VpcEndpoint(pulumi.ComponentResource):
    def __init__(
        self,
        name: str,
        vpc_id: str,
        region: str,
        subnet_ids: [str],
        security_group_ids: [str],
        opts: pulumi.ResourceOptions = None,
    ):
        super().__init__("my:aws:VpcEndpoint", name, {}, opts)

        # Define the STS VPC endpoint
        self.vpc_endpoint = aws.ec2.VpcEndpoint(
            f"{name}-sts-endpoint",
            vpc_id=vpc_id,
            service_name=f"com.amazonaws.{region}.sts",
            vpc_endpoint_type="Interface",  # Interface endpoint for STS
            private_dns_enabled=True,  # Enable private DNS resolution
            subnet_ids=subnet_ids,
            security_group_ids=security_group_ids,
            opts=pulumi.ResourceOptions(parent=self),
        )

        self.register_outputs({})
