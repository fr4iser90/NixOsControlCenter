#!/bin/bash

# Base installation paths
BASE_DIR="${HOME}"
export DOCKER_BASE_DIR="${BASE_DIR}/docker"
export DOCKER_SCRIPT_DIR="${BASE_DIR}/docker-scripts"
export DOCKER_LIB_DIR="${DOCKER_SCRIPT_DIR}/lib"

# Path helper functions
get_docker_dir() {
    local container=$1
    local category
    
    # Ensure MANAGEMENT_CATEGORIES is available
    if [ -z "${MANAGEMENT_CATEGORIES[*]}" ]; then
        echo "Error: MANAGEMENT_CATEGORIES not defined" >&2
        return 1
    }
    
    category=$(get_container_category "$container")
    if [ $? -eq 0 ]; then
        echo "$DOCKER_BASE_DIR/$category/$container"
        return 0
    fi
    
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