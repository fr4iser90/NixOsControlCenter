#!/bin/bash

# Standard script setup
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$(dirname "$SCRIPT_PATH")")"

# Verify script directory
if [ ! -f "${SCRIPT_DIR}/lib/core/imports.sh" ]; then
    echo "Error: Script directory structure invalid"
    echo "Expected: ${SCRIPT_DIR}/lib/core/imports.sh"
    exit 1
fi

# Source imports
source "${SCRIPT_DIR}/lib/core/imports.sh"

# Set error handling
set -euo pipefail

# Enable debug mode if requested
if [[ "${1:-}" == "--debug" ]]; then
    set -x
    print_status "Debug mode enabled" "info"
fi