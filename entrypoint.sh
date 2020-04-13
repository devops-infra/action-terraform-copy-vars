#!/usr/bin/env bash

set -e

# Return code
RET_CODE=0

# Run main action
python /terraform-copy-vars.py
RET_CODE=$?

# List of changed files
FILES_CHANGED=$(git diff --staged --name-status)

# Info about changed files
if [[ -n ${FILES_CHANGED} ]]; then
  echo " "
  echo "[INFO] Updated files:"
  for FILE in ${FILES_CHANGED}; do
    echo "${FILE}"
  done
  echo " "
else
  echo " "
  echo "[INFO] No files updated."
  echo " "
fi

# Fail if needed
if [[ ${INPUT_FAIL_ON_MISSING} == "true" && ${RET_CODE} != "0" ]]; then
  echo " "
  echo "[ERROR] Not all variables where properly defined."
  echo " "
  exit 1
else
  # Pass in other cases
  echo " "
  echo "[INFO] No errors found."
  echo " "
  exit 0
fi
