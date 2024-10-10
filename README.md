# backstage-microservice-template

WIP project to deploy Backstage on AWS EKS to be used in the future as a tool for developers to contribute and deploy templates for basically, whatever.

### Current state

Infrastructure is almost sorted. Automated deployment of EKS cluster using Terraform/Terragrunt and Pulumi to deploy applications to that cluster.

TODO:
- add load balancer addon & make deployment public
- create domain
- optimalize build times
- add linters for Pulumi & Backstage

## Design

Once Backstage is deployed, try to create everything else with templates so we can start making contributions.

## CI/CD

1. GitHub workflows will run lint on each PR and this check is required before merging
2. Build docker image -> build.yml
3. Deploy terragrunt/<path>/core infrastructure with TF -> deploy.yml
4. Deploy apps on EKS -> infra.yml

## App

Backstage should be pretty barebone. Just functioning environment integrated with GitHub (auth + access). For Backstage plugins use for start the basic ones as PRs, CI/CD.

## Infra

EKS should be cost efficient (it isn't now) so probably switch to FARGATE later on or make the whole things serverless. Also add PROD environment, could be under same AWS account.

EKS addons:
- csi-secret-store-driver: We're using SSM parameter store as our storage for secrets so we need addon to load secrets safely to EKS & containers
- load-balancer: We want ALB to be created by EKS so we need this addon as well
- open-telemetry: For monitoring

### About the Terragrunt structure

It's pretty basic DIR structure -> root/environment/provider/app/stack/module/terragrunt.hcl

To keep the code DRY, we try to keep in the lowest root/environment/provider/app/stack/module/terragrunt.hcl just includes. And keep most of the common configuration in _common/_common.yml or _common/module.hcl   -> You can still override values on the base level.

For most of the modules we're using official ones so we don't need to keep any TF code, but for some smaller modules we do so check out /terraform folder. But since switch to Pulumi we should not be deploying any TF code to EKS, keeping the folder in git just in case.

## Monitoring

Add openTelemetry in the future, since it can easily be added to EKS and monitor infrastructure and probably host Grafana, Prometheus or look for better solution so we can keep low cost. 

## Alerting

Integrate monitorign either with Slack, but most probably with Discord to notify about deployments, incidents, PRs, etc...

## Templates

My vision for templates is to be whatever they want to be, however I'd like to focus on making Pulumi reusable templates, as they can be done more transparent and object oriented then TF modules. All templates should be for everybody to use


## Known issues and improvements

Right now, EKS module will create some basic aws-auth configMap so you have to edit it manually to add your user to it.

csi-store-driver is deployed with TG but it's not as part of the pipeline anymore. Also it was having some issues using just the HelmChart so you have to add aws-provder manually.