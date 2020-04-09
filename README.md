# Copy variables to many Terraform modules at once

Dockerized ([christophshyper/action-terraform-copy-vars](https://hub.docker.com/repository/docker/christophshyper/action-terraform-copy-vars)) GitHub Action automatically updating Terraform definitions from a file `all_vars_file` to all files named `files_with_vars` in directories matching `dirs_with_modules` and committing fixed files back to the current branch.

So it's main use will be everywhere where [Terraform](https://github.com/hashicorp/terraform).

Main action is using a Python script.


## Badge swag
[
![GitHub](https://img.shields.io/badge/github-ChristophShyper%2Faction--terraform--copy--vars-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/christophshyper/action-terraform-copy-vars?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/christophshyper/action-terraform-copy-vars?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
![On each commit push](https://img.shields.io/github/workflow/status/christophshyper/action-terraform-copy-vars/On%20each%20commit%20push?color=brightgreen&label=Actions&logo=github&style=flat-square)
](https://github.com/christophshyper/action-terraform-copy-vars "shields.io")

[
![DockerHub](https://img.shields.io/badge/docker-christophshyper%2Faction--terraform--copy--vars-blue.svg?style=flat-square&logo=docker)
![Dockerfile size](https://img.shields.io/github/size/christophshyper/action-terraform-copy-vars/Dockerfile?label=Dockerfile&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/action-terraform-copy-vars?color=blue&label=Pulls&logo=docker&style=flat-square)
![Docker version](https://img.shields.io/docker/v/christophshyper/action-terraform-copy-vars?color=blue&label=Version&logo=docker&style=flat-square)
](https://hub.docker.com/r/christophshyper/action-terraform-copy-vars "shields.io")


## Usage

Input Variable | Required | Default |Description
:--- | :---: | :---: | :---
dirs_with_modules | No | `terraform` | Comma separated list of directory prefixes with modules.
files_with_vars | No | `variables.tf` | Comma separated list of files containing variables in directories matching `dirs_with_modules`.
all_vars_file | No | `all-variables.tf` | Name of a file containing base definitions of all variables. 
fail_on_missing | No | `false` | Whether action should fail if `all_vars_file` is missing some definitions from modules. 
push_changes | No | `false` | Whether changes should be pushed back to the current branch.
github_token | No | `""` | Personal Access Token for GitHub. If `push_changes` set to true. 

If `push_changes` is set to `true` then `fail_on_changes` will be treated as `false`.


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
    - name: Checkout
      uses: actions/checkout@v2
    - name: Fail on different veriables' definitions
      uses: docker://christophshyper/action-terraform-copy-vars:latest
      with:
        fail_on_changes: true
```

Copy variables definitions from `all-variables.tf` to all `variables.tf` in `modules` subdirectories and commit them back to repository.
```yaml
name: Copy Terraform variables accross modules
on:
  push
jobs:
  terraform-copy-vars:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Update Terraform variables
      uses: docker://christophshyper/action-terraform-copy-vars:latest
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        push_changes: true
        dirs_with_modules: modules
```
