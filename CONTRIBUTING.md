# Contributing

This document provides guidelines for contributing to the CloudBees CD/RO add-on for Amazon EKS blueprints.

## Dependencies

Validate your changes inside the blueprint agent, as described in [Dockerfile](blueprints/Dockerfile). For example, it can be used to run `make dBuildAndRun`.

## Report bugs and feature requests

CloudBees welcomes you to use the GitHub issue tracker to report bugs or suggest features.

When filing an issue:

1. Check existing open and recently closed [issues](https://github.com/cloudbees/terraform-aws-cloudbees-cd-eks-addon/issues) to ensure the issue has not already been reported.
1. Review the upstream repositories:
    - [aws-ia/terraform-aws-eks-blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints/issues)
    - [aws-ia/terraform-aws-eks-blueprints-addons](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/issues)
1. Try to include as much information as you can. Details like the following are incredibly useful:
    - A reproducible test case or series of steps
    - The version of code being used
    - Any modifications you have made relevant to the bug
    - Anything unusual about your environment or deployment

## Contribute via pull requests

Contributions via pull requests are appreciated. Before submitting a pull request, please ensure that you:

1. Are working against the latest source on the `main` branch.
1. Check existing open, and recently merged, pull requests to make sure someone else has not already addressed the problem.
1. Open an issue to discuss any significant work; we do not want your time to be wasted.

To submit a pull request:

1. Fork the repository.
1. Create a feature branch based on the `main` branch.
1. Modify the source and focus on the specific change you are contributing. For example, if you reformat all the code, it is hard for reviewers to focus on your specific change.
1. **Ensure that local tests pass**. Local tests can be orchestrated via the companion [Makefile](Makefile).
1. Make commits to your fork using clear commit messages.
1. Submit a pull request against the `main` branch and answer any default questions in the pull request interface.
1. Pay attention to any automated failures reported in the pull request, and stay involved in the conversation.

> [!IMPORTANT]
> If you make updates to the embedded repository, you must push the changes to the public upstream (repository/branch) before running `terraform apply` locally. The endpoint and/or branch can be updated via the companion [Makefile](Makefile).

## Pre-commits: Linting, Formatting and Secrets Scanning

Many of the files in the repository can be linted or formatted to maintain a standard of quality. Additionally, secret leaks are watched via [gitleaks](https://github.com/zricethezav/gitleaks#pre-commit) and [git-secrets](https://github.com/awslabs/git-secrets).

1. When working with the repository for the first time, you must install `pre-commit`. For more information, refer to [pre-commit installation](https://pre-commit.com/#installation).
1. Run `pre-commit run --all-files`. Run this command again if the automated checks fail when you create a pull request.

## Release Drafter

This repository uses [Release Drafter](https://github.com/release-drafter/release-drafter). Therefore, it is recommended that you use [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716) to label your pull requests accordingly.