#!/usr/bin/env bash

set -e

# Return code
RET_CODE=0

# Run main action
python3 /terraform-copy-vars.py
RET_CODE=$?

# List of changed files
FILES_CHANGED=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  FILES_CHANGED=$(git diff --cached --name-status 2>/dev/null || true)
  if [[ -z ${FILES_CHANGED} ]]; then
    FILES_CHANGED=$(git diff --name-status 2>/dev/null || true)
  fi
fi

# Info about changed files
if [[ -n ${FILES_CHANGED} ]]; then
  echo -e "\n[INFO] Updated files:"
  for FILE in ${FILES_CHANGED}; do
    echo "${FILE}"
  done
else
  echo -e "\n[INFO] No files updated."
fi

# Fail if needed
if [[ ${INPUT_FAIL_ON_MISSING} == "true" && ${RET_CODE} != "0" ]]; then
  echo -e "\n[ERROR] Not all variables where properly defined."
  exit 1
else
  # Pass in other cases
  echo -e "\n[INFO] No errors found."
  exit 0
fi
