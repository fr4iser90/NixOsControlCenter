#!/bin/bash

# Standard script setup - DO NOT MODIFY
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Verify and source script-header
if [ ! -f "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh" ]; then
    echo "Error: Cannot find script-header.sh"
    exit 1
fi

source "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh"

# ==============================================
# Docker Service Functions
# ==============================================

start_docker_container() {
    local container=$1
    local docker_dir=$(get_docker_dir "$container")

    if [ -z "$docker_dir" ]; then
        print_status "Invalid container: $container" "error"
        return 1
    fi

    print_status "Starting $container" "info"

    # Check for update-env.sh
    if [ -f "$docker_dir/update-env.sh" ]; then
        print_status "Running environment updates..." "info"
        (cd "$docker_dir" && bash update-env.sh)
    fi

    if [ -d "$docker_dir" ]; then
        (cd "$docker_dir" && docker compose up -d)
        print_status "Container started successfully" "success"
        return 0
    else
        print_status "Container directory not found" "error"
        return 1
    fi
}

restart_docker_container() {
    local container=$1
    local docker_dir=$(get_docker_dir "$container")

    if [ -z "$docker_dir" ]; then
        print_status "Invalid container: $container" "error"
        return 1
    fi

    if [ -d "$docker_dir" ]; then
        print_status "Restarting $container" "info"
        (cd "$docker_dir" && docker compose up -d --force-recreate)
        print_status "Container restarted successfully" "success"
        return 0
    else
        print_status "Container directory not found" "error"
        return 1
    fi
}