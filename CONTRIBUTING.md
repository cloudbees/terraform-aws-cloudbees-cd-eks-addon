# Contributing

This document provides guidelines for contributing to the CloudBees CD/RO add-on for Amazon EKS blueprints.

## Dependencies

Validate your changes inside the blueprint-agent described in [.Dockerfile](blueprints/Dockerfile). It can be run `make dBuildAndRun`.

## Report bugs and feature requests

CloudBees welcomes you to use the GitHub issue tracker to report bugs or suggest features.

When filing an issue:

1. Check existing open and recently closed [issues](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/issues) to ensure the issue has not already been reported.
2. Review the upstream repositories:
    - [aws-ia/terraform-aws-eks-blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints/issues)
    - [aws-ia/terraform-aws-eks-blueprints-addons](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/issues)
3. Try to include as much information as you can. Details like the following are incredibly useful:
    - A reproducible test case or series of steps
    - The version of code being used
    - Any modifications you have made relevant to the bug
    - Anything unusual about your environment or deployment

## Pre-commits: Linting, Formatting and Secrets Scanning

Many of the files in the repository can be linted or formatted to maintain a standard of quality. Additionally, secret leaks are watched via [gitleaks](https://github.com/zricethezav/gitleaks#pre-commit) and [git-secrets](https://github.com/awslabs/git-secrets).

1. When working with the repository for the first time, you must install `pre-commit`. For more information, refer to [pre-commit installation](https://pre-commit.com/#installation).
2. Run `pre-commit run --all-files`. Run this command again if the automated checks fail when you create a pull request.

## Release Drafter

This repository uses [Release Drafter](https://github.com/release-drafter/release-drafter) thus it is recommended to use [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716) to ease labelling your pull request accordingly.