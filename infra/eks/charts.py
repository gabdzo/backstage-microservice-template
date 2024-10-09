import pulumi
import pulumi_kubernetes as k8s


class HelmChart(pulumi.ComponentResource):
    def __init__(
        self,
        name: str,
        chart: str,
        version: str,
        repo: str,
        namespace: str,
        values: dict = None,
        set_values: dict = None,  # Optional dict for 'set' equivalent
        opts: pulumi.ResourceOptions = None,
    ):
        super().__init__("my:helm:HelmChart", name, {}, opts)

        # Helm chart installation with set_values logic
        chart_values = values if values else {}

        if set_values:
            for key, value in set_values.items():
                chart_values[key] = value

        self.chart = k8s.helm.v3.Chart(
            name,
            k8s.helm.v3.ChartOpts(
                chart=chart,
                version=version,
                fetch_opts=k8s.helm.v3.FetchOpts(
                    repo=repo,
                ),
                namespace=namespace,
                values=chart_values,
            ),
            opts=pulumi.ResourceOptions(parent=self),
        )

        self.register_outputs({})
