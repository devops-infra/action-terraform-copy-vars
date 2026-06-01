#!/usr/bin/env bash

set -euo pipefail

IMAGE_TAG="action-terraform-copy-vars:test"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

mkdir -p "${TMP_DIR}/terraform/module_a"

cat > "${TMP_DIR}/all-variables.tf" <<'EOF'
variable "region" {
  description = "Cloud region for deployment"
  type        = string
  default     = "us-east-1"
}
EOF

cat > "${TMP_DIR}/terraform/module_a/variables.tf" <<'EOF'
variable "region" {
  description = "Outdated description"
  type        = string
  default     = "us-east-1"
}
EOF

docker build -t "${IMAGE_TAG}" .

docker run --rm \
  -e INPUT_DIRS_WITH_MODULES=terraform \
  -e INPUT_FILES_WITH_VARS=variables.tf \
  -e INPUT_ALL_VARS_FILE=all-variables.tf \
  -e INPUT_FAIL_ON_MISSING=false \
  -v "${TMP_DIR}:/github/workspace" \
  -w /github/workspace \
  "${IMAGE_TAG}"

grep -q 'description = "Cloud region for deployment"' "${TMP_DIR}/terraform/module_a/variables.tf"
