# CloudBees CD/RO add-on for Amazon EKS blueprints

<p align="center">
  <a href="https://www.cloudbees.com/capabilities/continuous-delivery"><img alt="cloudbees-icon" src="https://images.ctfassets.net/vtn4rfaw6n2j/7FKeUjwsXI1d2JPUIvSMZJ/be286872ace9ca3b6b66a64adbb3c16a/cb-tag-sm.svg?fm=webp&q=85" height="120px" /></a>
  <p align="center">Deploy CloudBees CD/RO to Amazon Web Services (AWS) Elastic Kubernetes Service (EKS) clusters
</p>

---

![GitHub Latest Release)](https://img.shields.io/github/v/release/cloudbees/terraform-aws-cloudbees-cd-eks-addon?logo=github) ![GitHub Issues](https://img.shields.io/github/issues/cloudbees/terraform-aws-cloudbees-cd-eks-addon?logo=github) [![Code Quality: Terraform](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform.yml) [![Code Quality: Super-Linter](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/superlinter.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/superlinter.yml) [![Documentation: MD Links Checker](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/md-link-checker.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/md-link-checker.yml) [![Documentation: terraform-docs](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform-docs.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform-docs.yml) [![gitleaks badge](https://img.shields.io/badge/protected%20by-gitleaks-blue)](https://github.com/zricethezav/gitleaks#pre-commit) [![gitsecrets](https://img.shields.io/badge/protected%20by-gitsecrets-blue)](https://github.com/awslabs/git-secrets)

## Motivation

The CloudBees CD/RO AWS add-on streamlines the adoption and experimentation of CloudBees CD/RO enterprise features by:

- Encapsulating the deployment of [CloudBees CD/RO in AWS EKS](https://docs.cloudbees.com/docs/cloudbees-cd/latest/install-k8s/) into a Terraform module.
- Providing a series of opinionated [blueprints](blueprints) that implement the CloudBees CD/RO add-on module for use with [Amazon EKS blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/) which are aligned with the [EKS Best Practices Guides](https://aws.github.io/aws-eks-best-practices/).

## CloudBees CD/RO license
You must have a valid license to operate the CloudBees CD/RO server. By default, CloudBees CD/RO uses the server license type. For more information, refer to [Licenses](https://docs.cloudbees.com/docs/cloudbees-cd/latest/set-up-cdro/licenses).

## Usage

Implementation examples are included in the [blueprint](blueprints) folder, however this is the simplest example of usage:

```terraform
module "eks_blueprints_addon_cbcd" {
  source = "REPLACE_ME"

  host_name     = "example"
  hosted_zone   = "domain.com"
  cert_arn     = "arn:aws:acm:us-east-1:0000000:certificate/0000000-aaaa-bbb-ccc-thisIsAnExample"
}
```

By default, it uses a minimum required configuration described in the Helm chart [values.yml](values.yml). If you need to override any default settings with the chart, you can do so by passing the `helm_config` variable.

## Prerequisites

### Tooling

The blueprint `deploy` and `destroy` phases use the same requirements provided in the [AWS EKS Blueprints for Terraform - Prerequisites](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites). However, the blueprint `validate` phase may require additional tooling, such as `jq` and `velero`.

> [!NOTE]
> There is a companion [Dockerfile](blueprints/Dockerfile) to run the blueprints in a containerized development environment, ensuring all dependencies are met. It can be built locally using the [Makefile](Makefile) target `make dRun`.

### AWS authentication

Before getting started, you must export your required [AWS Environment Variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) to your CLI (for example, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_PROFILE`).

### Existing AWS 53 hosted zone

These blueprints rely on an existing hosted zone in AWS Route 53. If you do not have a hosted zone, you can create one by following the [AWS Route 53 documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html).

## Data storage options

CloudBees CD/RO uses a file system to persist data. Data is stored in several [locations](https://docs.cloudbees.com/docs/cloudbees-cd/latest/requirements/k8s-requirements#persist) and configured to be stored in Amazon Elastic Block Store (Amazon EBS) or Amazon Elastic File System (Amazon EFS)

- Amazon EBS volumes are scoped to a particular availability zone to offer high-speed, low-latency access to the Amazon Elastic Compute Cloud (Amazon EC2) instances they are connected to. If an availability zone fails, an Amazon EBS volume becomes inaccessible due to file corruption, or there is a service outage, the data on these volumes becomes inaccessible. The pods require this persistent data and have no mechanism to replicate the data, so CloudBees recommends frequent backups for Amazon EBS.
- Amazon EFS file systems are scoped to an AWS region and can be accessed from any availability zone in the region that the file system was created in. Using Amazon EFS as a storage class allows pods to be rescheduled successfully onto healthy nodes in the event of an availability zone outage. Amazon EFS is more expensive than Amazon EBS, but provides greater fault tolerance.

> [!IMPORTANT]  
> CloudBees CD/RO clustered mode requires Amazon EFS. For more information, refer to [CloudBees CD/RO EKS Storage Requirements](https://docs.cloudbees.com/docs/cloudbees-cd/latest/requirements/k8s-requirements#persist).

> [!NOTE]
> For more information on pricing and cost analysis, refer to [Amazon EBS pricing](https://aws.amazon.com/ebs/pricing/) and [Amazon EFS pricing](https://aws.amazon.com/efs/pricing/).

## Terraform documentation

<!-- BEGIN_TF_DOCS -->
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cert_arn | Certificate ARN from AWS ACM | `string` | n/a | yes |
| host_name | Route53 Host name | `string` | n/a | yes |
| flow_db_secrets_file | Secrets file yml path containing the secrets names:values to create the Kubernetes secret flow_db_secret. | `string` | `"flow_db_secrets-values.yml"` | no |
| helm_config | CloudBees CD Helm chart configuration | `any` | <pre>{<br>  "values": [<br>    ""<br>  ]<br>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| cbcd_domain_name | Route 53 Domain Name to host CloudBees CD Services. |
| cbcd_flowserver_pod | Flow Server Pod for CloudBees CD Add-on. |
| cbcd_ing | Ingress for the CloudBees CD add-on. |
| cbcd_liveness_probe_int | CD service internal liveness probe for the CloudBees CD add-on. |
| cbcd_namespace | Namespace for CloudBees CD Addon. |
| cbcd_password | Command to get the admin password of Cloudbees CD |
| cbcd_url | URL for CloudBees CD Add-on. |
| merged_helm_config | (merged) Helm Config for CloudBees CD |
<!-- END_TF_DOCS -->

## Additional resources

- [CloudBees CD/RO documentation](https://docs.cloudbees.com/docs/cloudbees-cd/latest/)
- [CloudBees CD/RO release notes](https://docs.cloudbees.com/docs/release-notes/latest/cloudbees-cd/)
- [Architecture for CloudBees CD/RO](https://docs.cloudbees.com/docs/cloudbees-cd/latest/architecture/)
- [Amazon EKS Blueprints Addons](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/)
- [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- [Containers: Bootstrapping clusters with EKS Blueprints](https://aws.amazon.com/blogs/containers/bootstrapping-clusters-with-eks-blueprints/)
- [EKS Workshop](https://www.eksworkshop.com/)
