#!/usr/bin/env python

import os
import re


"""
Script for copying Terraform variables' definitions across whole modules monorepo from a single place.
How it works:
- Searches for all files defined in a comma separated list INPUT_FILES_WITH_VARS.
- Searches only in subdirectories defined in a comma separated list INPUT_DIRS_WITH_MODULES.
- Reads a file INPUT_ALL_VARS_FILE and replacing its matching variables in files found in previous steps.
- Reports if INPUT_ALL_VARS_FILE don't contain variables in some modules from INPUT_DIRS_WITH_MODULES.

Copyright (c) 2020 Krzysztof Szyper / ChristophShyper (https://christophshyper.github.io/)
Part of GitHub Action from https://github.com/devops-infra/action-terraform-copy-vars
"""


# read parameters from env vars
tf_dir_filters = os.getenv("INPUT_DIRS_WITH_MODULES").split(",")
tf_var_files = os.getenv("INPUT_FILES_WITH_VARS").split(",")
tf_all_vars_file = os.getenv("INPUT_ALL_VARS_FILE")

# regex for parsing variable definition
regex = '(variable\s\"(.*)\")([\S\s]*?)(?=\s*variable\s\"|\s*\Z)'


# main handler function
def handler():
    found = find_non_defined()
    changed = copy_definitions()
    if changed != "":
        print("\n[INFO] Following variables had been copied {}".format(changed))
    if found == "":
        exit(0)
    else:
        print("\n[ERROR] Following variables are not defined in {}{}".format(tf_all_vars_file, found))
        exit(1)


# find variables in files from var_files and report missing in tf_all_vars_file
def find_non_defined():
    all_vars_list = get_all_vars(tf_all_vars_file)
    var_files = find_var_files()
    output = ""
    for file in var_files:
        file_vars = get_all_vars(file)
        for source_var in file_vars:
            found = False
            for target_var in all_vars_list:
                # find matching variables' names
                if source_var[1] == target_var[1]:
                    found = True
            if not found:
                output += "\n\nFile: {} / Variable: {}".format(file, source_var[1]).replace(get_cwd(), "")
    return output


# copy variables from tf_all_vars_file to var_files
def copy_definitions():
    # get all source variables
    all_vars_list = get_all_vars(tf_all_vars_file)
    # find all wanted files
    var_files = find_var_files()
    output = ""
    for file in var_files:
        file_vars = get_all_vars(file)
        file_cont = read_file(file)
        for source_var in all_vars_list:
            for target_var in file_vars:
                # find matching variables' names
                if source_var[1] == target_var[1]:
                    source = "{}{}".format(source_var[0], source_var[2])
                    target = "{}{}".format(target_var[0], target_var[2])
                    if source != target:
                        file_cont = file_cont.replace(target, source)
                        output += "\n\nFile: {} / Variable: {}".format(file, source_var[1]).replace(get_cwd(), "")
        # print("new: {}".format(file_cont))
        write_file(file, file_cont)
    return output


# get list of all variables' definitions in a file
def get_all_vars(file):
    cont = read_file(file)
    vars_list = re.findall(regex, cont, re.MULTILINE)
    return vars_list


# write to a file
def write_file(file, content):
    f = open(file, "w")
    f.write(content)
    f.close()


# read a file
def read_file(file):
    f = open(file, "r")
    cont = f.read()
    return cont


# find all .tf files with variables to replace
def find_var_files():
    curr_dir = get_cwd()
    files_list = []
    for root, dirs, files in os.walk(curr_dir):
        for tf_dir in tf_dir_filters:
            if root.startswith("{}/{}".format(curr_dir, tf_dir)):
                for file in files:
                    for tf_var_file in tf_var_files:
                        if file.endswith(tf_var_file):
                            files_list.append("{}/{}".format(root, file))
    return files_list


# get current directory
def get_cwd():
    dir_path = os.getcwd()
    return dir_path


# run it as a script
if __name__ == '__main__':
    handler()
