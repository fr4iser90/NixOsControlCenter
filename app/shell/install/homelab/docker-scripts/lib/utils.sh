#!/bin/bash

# Get absolute path to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"


# Common utility functions
generate_random_string() {
    nix-shell -p openssl --run "openssl rand -base64 ${1:-32}"
}

escape_for_sed() {
    echo "$1" | sed -e 's/[\/&]/\\&/g'
}
