#!/usr/bin/env python3
# pylint: disable=invalid-name
"""Copy Terraform variable definitions from a shared file to module files.

How it works:
- Searches for files matching INPUT_FILES_WITH_VARS.
- Searches only under directories from INPUT_DIRS_WITH_MODULES.
- Reads INPUT_ALL_VARS_FILE and replaces matching variables in found files.
- Reports variables used in modules that are missing in INPUT_ALL_VARS_FILE.

Copyright (c) 2020 Krzysztof Szyper / ChristophShyper
Part of GitHub Action from https://github.com/devops-infra/action-terraform-copy-vars
"""

import os
import re
import sys


def _read_list_input(env_name):
    """Read comma-separated env input into trimmed non-empty values."""
    raw_value = os.getenv(env_name, "")
    return [item.strip() for item in raw_value.split(",") if item.strip()]


TF_DIR_FILTERS = _read_list_input("INPUT_DIRS_WITH_MODULES")
TF_VAR_FILES = _read_list_input("INPUT_FILES_WITH_VARS")
TF_ALL_VARS_FILE = os.getenv("INPUT_ALL_VARS_FILE", "").strip()

VARIABLE_BLOCK_REGEX = r'(variable\s\"(.*)\")([\S\s]*?)(?=\s*variable\s\"|\s*\Z)'


def handler():
    """Run missing-variable detection and copy/update definitions."""
    missing = find_non_defined()
    changed = copy_definitions()

    if changed:
        print(f"\n[INFO] Following variables had been copied {changed}")

    if missing:
        print(f"\n[ERROR] Following variables are not defined in {TF_ALL_VARS_FILE}{missing}")
        sys.exit(1)

    sys.exit(0)


def _format_change_message(file_path, variable_name, cwd_path):
    """Build human-readable info line for a changed variable."""
    return f"\n\nFile: {file_path} / Variable: {variable_name}".replace(cwd_path, "")


def find_non_defined():
    """Find variables used in module files but missing in the central file."""
    all_var_names = {var_def[1] for var_def in get_all_vars(TF_ALL_VARS_FILE)}
    output = ""
    cwd_path = get_cwd()

    for file_path in find_var_files():
        for source_var in get_all_vars(file_path):
            if source_var[1] not in all_var_names:
                output += _format_change_message(file_path, source_var[1], cwd_path)

    return output


def copy_definitions():
    """Copy and append variable definitions from central file to module files."""
    all_vars_list = get_all_vars(TF_ALL_VARS_FILE)
    output = ""
    cwd_path = get_cwd()

    for file_path in find_var_files():
        file_vars = get_all_vars(file_path)
        file_vars_by_name = {var_def[1]: var_def for var_def in file_vars}
        file_content = read_file(file_path)

        for source_var in all_vars_list:
            source_name = source_var[1]
            source_block = f"{source_var[0]}{source_var[2]}"
            target_var = file_vars_by_name.get(source_name)

            if target_var is not None:
                target_block = f"{target_var[0]}{target_var[2]}"
                if source_block != target_block:
                    file_content = file_content.replace(target_block, source_block)
                    output += _format_change_message(file_path, source_name, cwd_path)
                continue

            file_content = f"{file_content.rstrip()}\n\n{source_block.strip()}\n"
            output += _format_change_message(file_path, source_name, cwd_path)

        write_file(file_path, file_content)

    return output


def get_all_vars(file_path):
    """Extract Terraform variable blocks from a file."""
    content = read_file(file_path)
    return re.findall(VARIABLE_BLOCK_REGEX, content, re.MULTILINE)


def write_file(file_path, content):
    """Write content to file with UTF-8 encoding."""
    with open(file_path, "w", encoding="utf-8") as file_handle:
        file_handle.write(content)


def read_file(file_path):
    """Read file content with UTF-8 encoding."""
    with open(file_path, "r", encoding="utf-8") as file_handle:
        return file_handle.read()


def _root_matches_filter(root_path, cwd_path):
    """Check whether root path is inside configured module directories."""
    for tf_dir in TF_DIR_FILTERS:
        if root_path.startswith(f"{cwd_path}/{tf_dir}"):
            return True
    return False


def _file_matches_filter(file_name):
    """Check whether file name matches configured variable file suffixes."""
    for tf_var_file in TF_VAR_FILES:
        if file_name.endswith(tf_var_file):
            return True
    return False


def find_var_files():
    """Find all variable files in selected module directories."""
    curr_dir = get_cwd()
    files_list = []

    for root, _, files in os.walk(curr_dir):
        if not _root_matches_filter(root, curr_dir):
            continue

        for file_name in files:
            if _file_matches_filter(file_name):
                files_list.append(f"{root}/{file_name}")

    return files_list


def get_cwd():
    """Get current working directory."""
    return os.getcwd()


if __name__ == "__main__":
    handler()
