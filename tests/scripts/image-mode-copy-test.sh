#!/usr/bin/env bash

set -euo pipefail

IMAGE_TAG="action-terraform-copy-vars:test"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

docker build -t "${IMAGE_TAG}" .

mkdir -p "${TMP_DIR}/terraform/module_a" "${TMP_DIR}/terraform/module_b"

cat > "${TMP_DIR}/all-variables.tf" <<'EOF'
variable "region" {
  description = "Cloud region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Resource name"
  type        = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
EOF

cat > "${TMP_DIR}/terraform/module_a/variables.tf" <<'EOF'
variable "region" {
  description = "Cloud region for deployment"
  type        = string
  default     = "us-east-1"
}
EOF

cat > "${TMP_DIR}/terraform/module_b/variables.tf" <<'EOF'
variable "name" {
  description = "Resource name"
  type        = string
}
EOF

docker run --rm \
  -e INPUT_DIRS_WITH_MODULES=terraform \
  -e INPUT_FILES_WITH_VARS=variables.tf \
  -e INPUT_ALL_VARS_FILE=all-variables.tf \
  -e INPUT_FAIL_ON_MISSING=false \
  -v "${TMP_DIR}:/github/workspace" \
  -w /github/workspace \
  "${IMAGE_TAG}"

grep -q 'variable "env"' "${TMP_DIR}/terraform/module_a/variables.tf"

mkdir -p "${TMP_DIR}/infra/services/api" "${TMP_DIR}/infra/services/db"

cat > "${TMP_DIR}/infra/all-vars.tf" <<'EOF'
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "version_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
EOF

cat > "${TMP_DIR}/infra/services/api/vars.tf" <<'EOF'
variable "app_name" {
  description = "Application name"
  type        = string
}
EOF

cat > "${TMP_DIR}/infra/services/db/vars.tf" <<'EOF'
variable "app_name" {
  description = "Application name"
  type        = string
}
EOF

docker run --rm \
  -e INPUT_DIRS_WITH_MODULES=infra/services \
  -e INPUT_FILES_WITH_VARS=vars.tf \
  -e INPUT_ALL_VARS_FILE=infra/all-vars.tf \
  -e INPUT_FAIL_ON_MISSING=false \
  -v "${TMP_DIR}:/github/workspace" \
  -w /github/workspace \
  "${IMAGE_TAG}"

grep -q 'variable "version_tag"' "${TMP_DIR}/infra/services/api/vars.tf"
