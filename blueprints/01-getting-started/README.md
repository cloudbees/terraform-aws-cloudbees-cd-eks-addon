# CloudBees CD/RO blueprint add-on: Get started

Get started with [CloudBees CD/RO in EKS](https://docs.cloudbees.com/docs/cloudbees-cd/latest/install-k8s/) by running this blueprint, which only installs the product and its [prerequisites](https://docs.cloudbees.com/docs/cloudbees-cd/latest/install-k8s/installation), to help you understand the minimum setup:

- Amazon Web Services (AWS) certificate manager
- The following [Amazon EKS blueprints add-ons](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/):
  - [AWS Load Balancer Controller](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/aws-load-balancer-controller/)
  - [External DNS](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/external-dns/)
  - [Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) to allocate Amazon EBS volumes for hosting Cloudbees CD/RO.

> [!TIP]
> A [resource group](https://docs.aws.amazon.com/ARG/latest/userguide/resource-groups.html) is added, to get a full list with all resources created by this blueprint.

## Architecture

![Architecture](img/getting-started.architect.drawio.svg)

### Kubernetes cluster

![Architecture](img/getting-started.k8s.drawio.svg)

## Terraform Docs

<!-- BEGIN_TF_DOCS -->
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| host_name | Host name. CloudBees CD Apps is configured to use this host name. | `string` | n/a | yes |
| hosted_zone | Route 53 Hosted Zone. CloudBees CD Apps is configured to use this hosted zone. | `string` | n/a | yes |
| suffix | Unique suffix to be assigned to all resources | `string` | `""` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| acm_certificate_arn | ACM certificate ARN |
| cbcd_helm | Helm configuration for CloudBees CD Add-on. It is accesible only via state files. |
| cbcd_namespace | Namespace for CloudBees CD Add-on. |
| cbcd_password | Command to get the admin password of Cloudbees CD |
| cbcd_url | URL of the CloudBees CD Operations Center for CloudBees CD Add-on. |
| eks_cluster_arn | EKS cluster ARN |
| kubeconfig_add | Add Kubeconfig to local configuration to access the K8s API. |
| kubeconfig_export | Export KUBECONFIG environment variable to access to access the K8s API. |
| vpc_arn | VPC ID |
<!-- END_TF_DOCS -->

## Deploy

When preparing to deploy, you must complete the following steps:

1. Customize your Terraform values by copying `.auto.tfvars.example` to `.auto.tfvars`.
1. Initialize the root module and any associated configuration for providers.
1. Create the resources and deploy CloudBees CD/RO to an EKS cluster. Refer to [Amazon EKS Blueprints for Terraform - Deploy](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#deploy).

For more information, refer to [The Core Terraform Workflow](https://www.terraform.io/intro/core-workflow) documentation.

## Validate

Once the blueprint has been deployed, you can validate it.

### Kubeconfig

Once the resources have been created, a `kubeconfig` file is created in the [/k8s](k8s) folder. Issue the following command to define the [KUBECONFIG](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable) environment variable to point to the newly generated file:

  ```sh
  eval $(terraform output --raw kubeconfig_export)
  ```

If the command is successful, no output is returned.

### CloudBees CD/RO

Once you can access the Kubernetes API from your terminal, complete the following steps.

1. DNS propagation may take several minutes. Once propagation is complete, issue the following command:

      ```sh
      terraform output cbcd_url
      ```
1. To access CloudBees CD/RO, paste the output of the previous command into a web browser.
1. Issue the following command to retrieve the initial administrative user password to sign in to CloudBees CD/RO:

      ```sh
      eval $(terraform output --raw cbcd_password)
      ```

## Destroy

To tear down and remove the resources created in the blueprint, complete the steps for [Amazon EKS Blueprints for Terraform - Destroy](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#destroy).

> [!TIP]
> The `destroy` phase can be orchestrated via the companion [Makefile](../../Makefile).
