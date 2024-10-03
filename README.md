# backstage-microservice-template
Template to deploy microservice to kubernetes. Idea is to either use this instance or users can deploy their own. Or use templates for their purpouses or add templates as contribution. That would be nice


TODO:

- ECR deployment
- K8S manifests
- sort out domain and host backstage
- do optimalized docker build 
- hopefully deploy backstage to AWS by the end of today

### Design

#### App
This repo should be a showcase to deploy Backstage to AWS on EKS.
    - EKS should be cost efficent, switch to FARGATE later on
    - should support multiple environments prod/staging/dev -> deployment for each PR
    - each deployment should have full functionality -> GitHub integration & authentication
    - Backstage itself should be pretty bare, we just want to run showcase templates

#### Templates
Template to deploy simple Hello World python microservice to AWS, GCP or Azure. User should have minimal necessary choice input, basically just select cloud. Outcome should be new repository with working CI/CD and live endpoint for helloworld
