#!/bin/bash

# Base installation paths
BASE_DIR="${HOME}"
export DOCKER_BASE_DIR="${BASE_DIR}/docker"
export DOCKER_SCRIPT_DIR="${BASE_DIR}/docker-scripts"
export DOCKER_LIB_DIR="${DOCKER_SCRIPT_DIR}/lib"

# Path helper functions
get_docker_dir() {
    local container=$1
    for category in "${!MANAGEMENT_CATEGORIES[@]}"; do
        if [[ " ${MANAGEMENT_CATEGORIES[$category]} " =~ " $container " ]]; then
            echo "$DOCKER_BASE_DIR/$category/$container"
            return 0
        fi
    done
    echo "Container $container not found" >&2
    return 1
}

get_lib_file() {
    local file=$1
    echo "$DOCKER_LIB_DIR/$file"
}

get_script_file() {
    local file=$1
    echo "$DOCKER_SCRIPT_DIR/$file"
}