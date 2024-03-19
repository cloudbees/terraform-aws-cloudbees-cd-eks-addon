# CloudBees CD Add-on getting started Blueprint

Get started with the [CloudBees CD on Modern in EKS](https://docs.cloudbees.com/docs/cloudbees-ci/latest/eks-install-guide/) by running this blueprint which just installs the product and its [prerequisites](https://docs.cloudbees.com/docs/cloudbees-ci/latest/eks-install-guide/installing-eks-using-helm#_prerequisites) to help you understand the minimum requirements.

- AWS Certificate Manager
- **[Amazon EKS Addons](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/)**:
  - [AWS Load Balancer Controller](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/aws-load-balancer-controller/)
  - [External DNS](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/external-dns/)
  - [EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) to allocate EBS volumes for hosting Cloudbees CD.

> [!TIP]
> A [Resource Group](https://docs.aws.amazon.com/ARG/latest/userguide/resource-groups.html) is added to get a full list with all resources created by this blueprint.

## Architecture

![Architecture](img/getting-started.architect.drawio.svg)

### Kubernetes Cluster

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

First of all, customize your terraform values by copying `.auto.tfvars.example` to `.auto.tfvars`.

Initialize the root module and any associated configuration for providers and finally create the resources and deploy CloudBees CD to an EKS Cluster. Please refer to [Getting Started - Amazon EKS Blueprints for Terraform - Deploy](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#deploy)

For more detailed information, see the documentation for the [Terraform Core workflow](https://www.terraform.io/intro/core-workflow).

Once deployed has finished, it is possible to check the generated AWS resources via Resource Groups.

## Validate

Once the resources have been created, note that a `kubeconfig` file has been created inside the respective `blueprint/k8s` folder. Start defining the Environment Variable [KUBECONFIG](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable) to point to the generated file.

  ```sh
  eval $(terraform output --raw kubeconfig_export)
  ```

Once you get access to K8s API from your terminal, validate that:

> [!NOTE]
> DNS propagation can take a few minutes

- Once propagation is ready, it is possible to access the CloudBees CD by copying the outcome of the below command in your browser.

  ```sh
  terraform output cbcd_url
  ```

Now that you’ve installed CloudBees CD, you’ll want to see your system in action. You will need the initial admin password to log in by run the following command in your terminal:

  ```sh
  eval $(terraform output --raw cbcd_password)
  ```

## Destroy

To teardown and remove the resources created in the blueprint, the typical steps of execution are as explained in [Getting Started - Amazon EKS Blueprints for Terraform - Destroy](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#destroy)
