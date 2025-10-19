# GitHub Action coping Terraform variables across modules
**GitHub Action automatically copying variables' definitions from a single file to many modules.**


## 📦 Available on
- **Docker Hub:** [devopsinfra/action-terraform-copy-vars:latest](https://hub.docker.com/repository/docker/devopsinfra/action-terraform-copy-vars)
- **GitHub Packages:** [ghcr.io/devops-infra/action-terraform-copy-vars:latest](https://github.com/orgs/devops-infra/packages/container/package/action-terraform-copy-vars)


## ✨ Features
* It's main use will be everywhere where [Terraform](https://github.com/hashicorp/terraform) is used with *more than one module in a **monorepo***.
* Reads file defined with `all_vars_file` and will use whole definitions of variables from it.
* For every module matching `dirs_with_modules` will search files matching `files_with_vars` and replace matching variables from `all_vars_file`.
* To not loose the changes combine with my other action [devops-infra/action-commit-push](https://github.com/devops-infra/action-commit-push).


## 🔗 Related Actions
**Perfect for automation workflows and integrates seamlessly with [devops-infra/action-commit-push](https://github.com/devops-infra/action-commit-push).**


## Badge swag
[
![GitHub repo](https://img.shields.io/badge/GitHub-devops--infra%2Faction--terraform--copy--vars-blueviolet.svg?style=plastic&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/action-terraform-copy-vars?color=blueviolet&logo=github&style=plastic&label=Last%20commit)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/action-terraform-copy-vars?color=blueviolet&label=Code%20size&style=plastic&logo=github)
![GitHub license](https://img.shields.io/github/license/devops-infra/action-terraform-copy-vars?color=blueviolet&logo=github&style=plastic&label=License)
](https://github.com/devops-infra/action-terraform-copy-vars "shields.io")
<br>
[
![DockerHub](https://img.shields.io/badge/DockerHub-devopsinfra%2Faction--terraform--copy--vars-blue.svg?style=plastic&logo=docker)
![Docker version](https://img.shields.io/docker/v/devopsinfra/action-terraform-copy-vars?color=blue&label=Version&logo=docker&style=plastic&sort=semver)
![Image size](https://img.shields.io/docker/image-size/devopsinfra/action-terraform-copy-vars/latest?label=Image%20size&style=plastic&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/action-terraform-copy-vars?color=blue&label=Pulls&logo=docker&style=plastic)
](https://hub.docker.com/r/devopsinfra/action-terraform-copy-vars "shields.io")


## 🏷️ Version Tags: vX, vX.Y, vX.Y.Z
This action supports three tag levels for flexible versioning:
- `vX`: latest patch of the major version (e.g., `v1`).
- `vX.Y`: latest patch of the minor version (e.g., `v1.2`).
- `vX.Y.Z`: fixed to a specific release (e.g., `v1.2.3`).


## 📖 API Reference
```yaml
    - name: Run the action
      uses: devops-infra/action-terraform-copy-vars@v0.2
      with:
        dirs_with_modules: modules
        files_with_vars: variables.tf
        all_vars_file: all-variables.tf
        fail_on_missing: false
```

### 🔧 Input Parameters
| Input Variable      | Required |      Default       | Description                                                                                     |
|:--------------------|:--------:|:------------------:|:------------------------------------------------------------------------------------------------|
| `dirs_with_modules` |    No    |    `terraform`     | Comma separated list of directory prefixes with modules.                                        |
| `files_with_vars`   |    No    |   `variables.tf`   | Comma separated list of files containing variables in directories matching `dirs_with_modules`. |
| `all_vars_file`     |    No    | `all-variables.tf` | Name of a file containing base definitions of all variables.                                    |
| `fail_on_missing`   |    No    |      `false`       | Whether action should fail if `all_vars_file` is missing some definitions from modules.         |


## 💻 Usage Examples

### 📝 Basic Example
Fail action if not all variables in `variables.tf` in `terraform` subdirectories match their definitions in `all-variables.tf`.
```yaml
name: Check Terraform variables
on:
  push
jobs:
  terraform-copy-vars:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repoistory
      uses: actions/checkout@v5

    - name: Fail on different variables' definitions
      uses: devops-infra/action-terraform-copy-vars@v0.2
      with:
        fail_on_changes: true
```

### 🔀 Advanced Example
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
      uses: actions/checkout@v5

    - name: Update Terraform variables
      uses: devops-infra/action-terraform-copy-vars@v0.2
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


## 🤝 Contributing
Contributions are welcome! See [CONTRIBUTING](https://github.com/devops-infra/.github/blob/master/CONTRIBUTING.md).
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 💬 Support
If you have any questions or need help, please:
- 📝 Create an [issue](https://github.com/devops-infra/action-terraform-copy-vars/issues)
- 🌟 Star this repository if you find it useful!
