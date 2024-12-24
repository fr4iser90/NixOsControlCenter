#!/bin/bash

# Base paths
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
LIB_DIR="$(dirname "$SCRIPT_DIR")"

# Core imports (Reihenfolge wichtig!)
source "$SCRIPT_DIR/containers.sh"  # Zuerst containers.sh für MANAGEMENT_CATEGORIES
source "$SCRIPT_DIR/path.sh"        # Dann path.sh, das MANAGEMENT_CATEGORIES nutzt

# Utils - Format
source "$LIB_DIR/utils/format/colors.sh"
source "$LIB_DIR/utils/format/output.sh"

# Utils - Input
source "$LIB_DIR/utils/input/prompt.sh"
source "$LIB_DIR/utils/input/validation.sh"

# Utils - Security
source "$LIB_DIR/utils/security/credentials.sh"
source "$LIB_DIR/utils/security/crypto.sh"
source "$LIB_DIR/utils/security/hash.sh"

# Utils - System
source "$LIB_DIR/utils/system/file.sh"
source "$LIB_DIR/utils/system/string.sh"

# Services
source "$LIB_DIR/services/docker.sh"
source "$LIB_DIR/services/firewall.sh"
source "$LIB_DIR/services/permissions.sh"

# DNS
source "$LIB_DIR/dns/dns-provider-select.sh"
source "$LIB_DIR/dns/dns-providers-list.sh"

# Verify all required files are loaded
verify_imports() {
    local required_vars=(
        "DOCKER_BASE_DIR"     # from path.sh
        "SHOW_CREDENTIALS"    # from credentials.sh
        "INFO"               # from colors.sh
    )

    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            # Nutze print_status wenn verfügbar, sonst echo
            if type print_status >/dev/null 2>&1; then
                print_status "Required variable $var is not set" "error"
            else
                echo "Error: Required variable $var is not set"
            fi
            exit 1
        fi
    done

    # Erfolgsmeldung
    if type print_status >/dev/null 2>&1; then
        print_status "All required imports verified" "success"
    fi
}

verify_imports