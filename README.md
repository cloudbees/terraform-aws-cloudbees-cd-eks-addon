# CloudBees CD Add-on for AWS EKS

![GitHub Latest Release)](https://img.shields.io/github/v/release/cloudbees/terraform-aws-cloudbees-ci-eks-addon?logo=github) ![GitHub Issues](https://img.shields.io/github/issues/cloudbees/terraform-aws-cloudbees-ci-eks-addon?logo=github) [![Code Quality: Terraform](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform.yml) [![Code Quality: Super-Linter](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/superlinter.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/superlinter.yml) [![Documentation: MD Links Checker](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/md-link-checker.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/md-link-checker.yml) [![Documentation: terraform-docs](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform-docs.yml/badge.svg?event=pull_request)](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/actions/workflows/terraform-docs.yml) [![gitleaks badge](https://img.shields.io/badge/protected%20by-gitleaks-blue)](https://github.com/zricethezav/gitleaks#pre-commit) [![gitsecrets](https://img.shields.io/badge/protected%20by-gitsecrets-blue)](https://github.com/awslabs/git-secrets)

> Deploy CloudBees CD to AWS EKS Clusters with this add-on.

## Usage

If you would like to override any defaults with the chart, you can do so by passing the `helm_config` variable.

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->

## Blueprints

### Getting Started

```bash
ROOT=getting-started/v4 make tfRun
```

```bash
ROOT=getting-started/v5 make tfRun
```

## References

- [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- [Amazon EKS Blueprints Addons](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/)
- [CloudBees CD Docs](https://docs.cloudbees.com/docs/cloudbees-cd/latest/)
- [CloudBees CD release notes](https://docs.cloudbees.com/docs/release-notes/latest/cloudbees-cd)