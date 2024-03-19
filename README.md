# CloudBees CD Add-on for AWS EKS

<p align="center">
  <a href="https://www.cloudbees.com/capabilities/continuous-integration"><img alt="cloudbees-icon" src="https://images.ctfassets.net/vtn4rfaw6n2j/4dkyIw9VG39voD21C18YJz/692394b012c1ad7f2fc192dd484fdd47/image-grid-800x480-page-cd-simplify-your-jenkins-experience.png" height="120px" /></a>
  <p align="center">Deploy CloudBees CD to AWS EKS Clusters with this add-on.</p>
</p>

---

![GitHub Latest Release)](https://img.shields.io/github/v/release/cloudbees/terraform-aws-cloudbees-cd-eks-addon?logo=github) ![GitHub Issues](https://img.shields.io/github/issues/cloudbees/terraform-aws-cloudbees-cd-eks-addon?logo=github) [![Code Quality: Terraform](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform.yml) [![Code Quality: Super-Linter](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/superlinter.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/superlinter.yml) [![Documentation: MD Links Checker](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/md-link-checker.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/md-link-checker.yml) [![Documentation: terraform-docs](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform-docs.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform-docs.yml) [![gitleaks badge](https://img.shields.io/badge/protected%20by-gitleaks-blue)](https://github.com/zricethezav/gitleaks#pre-commit) [![gitsecrets](https://img.shields.io/badge/protected%20by-gitsecrets-blue)](https://github.com/awslabs/git-secrets)

## Motivation

This [AWS Partner Addon](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/aws-partner-addons/) aims to ease the adoption and experimentation of CloudBees CD enterprise features by:

- Encapsulating the Deployment of [CloudBees CD Modern in AWS EKS](https://docs.cloudbees.com/docs/cloudbees-cd/latest/eks-install-guide/installing-eks-using-helm#_configuring_your_environment) into a Terraform module.
- Providing a series of [Blueprints](blueprints) implementing the mentioned CloudBees CD Addon module on top of [AWS Terraform EKS Addons](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/) which are aligned with [EKS Best Practices Guides](https://aws.github.io/aws-eks-best-practices/).

## Usage

There are examples of implementation included in the [blueprint](blueprints) folder but the simplest example of usage is as follows:

```terraform
module "eks_blueprints_addon_cbcd" {
  source = "REPLACE_ME"

  host_name     = "example"
  hosted_zone   = "domain.com"
  cert_arn     = "arn:aws:acm:us-east-1:0000000:certificate/0000000-aaaa-bbb-ccc-thisIsAnExample"
}
```

By default, it uses a minimum required configuration described in [values.yml](values.yml).

If you would like to override any defaults with the chart, you can do so by passing the `helm_config` variable.

> [!TIP]
> Blueprints lifecycle (`deploy` > `validate` > `destroy`) can be orchestrated via the companion [Makefile](Makefile).

## Prerequisites

### Tooling

Blueprint `deploy` and `destroy` phases use the same tooling requirement per [AWS EKS Blueprints - Getting Started Guide - Prerequisites](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites).

Nevertheless, the Blueprint `validate` phase might require additional toolings like `jq` and `velero`.

> [!NOTE]
> There is a companion [Dockerfile](blueprints/Dockerfile) to run the blueprints in a containerized Dev environment ensuring dependecies are met. It can be built by using the [Makefile](Makefile) target `make dRun`.

### AWS Authentication

Make sure to export your required [AWS Environment Variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) to your CLI before getting started (eg. `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` or `AWS_PROFILE`).

### Existing AWS Hosted Zone

These blueprints rely on an existing Hosted Zone in AWS Route53. If you don't have one, you can create one by following the [AWS Route53 documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html).

## Data Storage Options

The main components of CloudBees CD, use a file system to persist data. Data is stored in a couple of [places](https://docs.cloudbees.com/docs/cloudbees-cd/latest/requirements/k8s-requirements#persist) that can be configured to be stored in Amazon EBS or EFS:

- Amazon EBS volumes are scoped to a particular Availability Zone to offer high-speed, low-latency access to the EC2 instances they are connected to. If an Availability Zone fails, an EBS volume becomes inaccessible due to file corruption, or there is a service outage, the data on these volumes will become inaccessible. Operations Center and Managed Controller pods require this persistent data and have no mechanism to replicate the data, so we recommend frequent backups for Amazon EBS.
- Amazon EFS file systems are scoped to an AWS Region and can be accessed from any Availability Zone in the Region the file system was created in. Using Amazon EFS as a storage class for the Operations Center and Managed Controller allows pods to be rescheduled successfully onto healthy nodes in the event of an Availability Zone outage. Amazon EFS file systems may increase the cost of the deployment compared to the Amazon EBS option, but provide greater fault tolerance.

> [!IMPORTANT]  
> CloudBees CD clustered mode requires Amazon EFS. See [CloudBees CD EKS Storage Requirements](https://docs.cloudbees.com/docs/cloudbees-cd/latest/requirements/k8s-requirements#persist).

> [!NOTE]
> For more information on pricing, see the [Amazon EBS pricing page](https://aws.amazon.com/ebs/pricing/) and the [Amazon EFS pricing page](https://aws.amazon.com/efs/pricing/).

## Terraform Docs

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
| cbcd_domain_name | Route 53 Domain Name to host CloudBees CI Services. |
| cbcd_flowserver_pod | Flow Server Pod for CloudBees CD Add-on. |
| cbcd_namespace | Namespace for CloudBees CD Addon. |
| cbcd_url | URL for CloudBees CD Add-on. |
| merged_helm_config | (merged) Helm Config for CloudBees CD |
<!-- END_TF_DOCS -->

## Communications

Cloudbees' slack channel [#cbcd-eks-blueprints](https://cloudbees.slack.com/archives/C05NACAEM5H)

## References

- [CloudBees CD Docs](https://docs.cloudbees.com/docs/cloudbees-cd/latest/)
- [CloudBees CD release notes](https://docs.cloudbees.com/docs/release-notes/latest/cloudbees-cd/)
- [Architecture for CloudBees CD on modern cloud platforms](https://docs.cloudbees.com/docs/cloudbees-cd/latest/architecture/cd-cloud)
- [Amazon EKS Blueprints Addons](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/)
- [Amazon EKS Blueprints Patterns](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- [Bootstrapping clusters with EKS Blueprints | Containers](https://aws.amazon.com/blogs/containers/bootstrapping-clusters-with-eks-blueprints/)
