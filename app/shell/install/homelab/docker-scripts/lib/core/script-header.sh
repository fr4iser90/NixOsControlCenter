#!/bin/bash

# Standard script setup - DO NOT MODIFY
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Verify imports
if [ ! -f "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh" ]; then
    echo "Error: Cannot find imports.sh"
    exit 1
fi

source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Set error handling
set -euo pipefail

# Enable debug mode if requested
if [[ "${1:-}" == "--debug" ]]; then
    set -x
    print_status "Debug mode enabled" "info"
fi