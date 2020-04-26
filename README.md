# GitHub Action coping variables across many Terraform modules at once

GitHub Action automatically copying variables' definitions from a single file to many modules.

Dockerized as [christophshyper/action-terraform-copy-vars](https://hub.docker.com/repository/docker/christophshyper/action-terraform-copy-vars).

Features:
* It's main use will be everywhere where [Terraform](https://github.com/hashicorp/terraform) is used with *more than one module in a **monorepo***.
* Reads file defined with `all_vars_file` and will use whole definitions of variables from it.
* For every module matching `dirs_with_modules` will search files matching `files_with_vars` and replace matching variables from `all_vars_file`.
* To not loose the changes combine with my other action [devops-infra/action-commit-push](https://github.com/devops-infra/action-commit-push).


## Badge swag
[
![GitHub](https://img.shields.io/badge/github-devops--infra%2Faction--terraform--copy--vars-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/action-terraform-copy-vars?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/action-terraform-copy-vars?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
](https://github.com/devops-infra/action-terraform-copy-vars "shields.io")
[![Push to master](https://img.shields.io/github/workflow/status/devops-infra/action-terraform-copy-vars/Push%20to%20master?color=brightgreen&label=Master%20branch&logo=github&style=flat-square)
](https://github.com/devops-infra/action-terraform-copy-vars/actions?query=workflow%3A%22Push+to+master%22)
[![Push to other](https://img.shields.io/github/workflow/status/devops-infra/action-terraform-copy-vars/Push%20to%20other?color=brightgreen&label=Pull%20requests&logo=github&style=flat-square)
](https://github.com/devops-infra/action-terraform-copy-vars/actions?query=workflow%3A%22Push+to+other%22)
<br>
[
![DockerHub](https://img.shields.io/badge/docker-christophshyper%2Faction--terraform--copy--vars-blue.svg?style=flat-square&logo=docker)
![Dockerfile size](https://img.shields.io/github/size/devops-infra/action-terraform-copy-vars/Dockerfile?label=Dockerfile%20size&style=flat-square&logo=docker)
![Image size](https://img.shields.io/docker/image-size/christophshyper/action-terraform-copy-vars/latest?label=Image%20size&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/action-terraform-copy-vars?color=blue&label=Pulls&logo=docker&style=flat-square)
![Docker version](https://img.shields.io/docker/v/christophshyper/action-terraform-copy-vars?color=blue&label=Version&logo=docker&style=flat-square)
](https://hub.docker.com/r/christophshyper/action-terraform-copy-vars "shields.io")


## Reference
```yaml
    - name: Fail on different veriables' definitions
      uses: devops-infra/action-terraform-copy-vars@master
      with:
        fail_on_changes: true
```

Input Variable | Required | Default |Description
:--- | :---: | :---: | :---
dirs_with_modules | No | `terraform` | Comma separated list of directory prefixes with modules.
files_with_vars | No | `variables.tf` | Comma separated list of files containing variables in directories matching `dirs_with_modules`.
all_vars_file | No | `all-variables.tf` | Name of a file containing base definitions of all variables. 
fail_on_missing | No | `false` | Whether action should fail if `all_vars_file` is missing some definitions from modules. 


## Examples

Fail action if not all variables in `variables.tf` in `terragrunt` subdirectories match their definitions in `all-variables.tf`.
```yaml
name: Check Terraform variables
on:
  push
jobs:
  terraform-copy-vars:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repoistory
      uses: actions/checkout@v2
    - name: Fail on different veriables' definitions
      uses: devops-infra/action-terraform-copy-vars@master
      with:
        fail_on_changes: true
```

Copy variables definitions from `all-variables.tf` to all `variables.tf` in `modules` subdirectories and commit updated files back to the repository using my other action [devops-infra/action-commit-push](https://github.com/devops-infra/action-commit-push).
```yaml
name: Copy Terraform variables accross modules
on:
  push
jobs:
  terraform-copy-vars:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repoistory
      uses: actions/checkout@v2
    - name: Update Terraform variables
      uses: devops-infra/action-terraform-copy-vars@master
      with:
        dirs_with_modules: modules
        files_with_vars: variables.tf
        all_vars_file: all-variables.tf
    - name: Commit changes to repo
      uses: devops-infra/action-commit-push@master
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        commit_prefix: "[AUTO-VARIABLES]"
```
