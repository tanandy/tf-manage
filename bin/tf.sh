#!/bin/bash

### Framework boilerplate
###############################################################################
# calculate script root dir
ROOT_DIR="$( dirname $(realpath ${BASH_SOURCE[0]}) )"

# import bash framework
source "${ROOT_DIR}/../vendor/bash-framework/lib/import.sh"

# import TF wrapper modules
source "${ROOT_DIR}/../lib/import.sh"

### Input validation
###############################################################################
function usage {
    cmd="${BASH_SOURCE[0]##*/} <component> <module> <env> <vars> <action> [workspace]"
    error "Usage: ${cmd}"
    exit -1
}

# number of arguments
( [ "$#" -lt 5 ] || [ "$#" -gt 6 ] ) && usage

# gather input vars
_COMPONENT=${1}
_MODULE=${2}
_ENV=${3}
_VARS=${4}
_TF_ACTION=${5}
_WORKSPACE_OVERRIDE=${6:-workspace=}

### Load configuration
###############################################################################
__load_global_config
__load_project_config

### Check folder structure is valid
###############################################################################
__validate_product
__validate_component
__validate_module_dir
__validate_env_dir
__validate_config_path

### Check TF_ACTION is supported
###############################################################################
__validate_tf_action

### Switch to targeted module path
###############################################################################
info "Running from ${TF_MODULE_PATH}/${_MODULE}"
cd "${TF_MODULE_PATH}/${_MODULE}"

### Check terraform workspace exists and is active
###############################################################################
__validate_tf_workspace

### Build terraform action command
###############################################################################
__tf_controller
