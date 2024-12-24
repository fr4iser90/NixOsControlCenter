#!/bin/bash

# Nutze die definierten Pfade aus path.sh
source "${DOCKER_SCRIPTS_DIR}/lib/core/containers.sh"
source "${DOCKER_SCRIPTS_DIR}/lib/core/path.sh"

# Utils - Format
source "${DOCKER_LIB_DIR}/utils/format/colors.sh"
source "${DOCKER_LIB_DIR}/utils/format/output.sh"

# Utils - Input
source "${DOCKER_LIB_DIR}/utils/input/prompt.sh"
source "${DOCKER_LIB_DIR}/utils/input/validation.sh"

# Utils - Security
source "${DOCKER_LIB_DIR}/utils/security/credentials.sh"
source "${DOCKER_LIB_DIR}/utils/security/crypto.sh"
source "${DOCKER_LIB_DIR}/utils/security/hash.sh"

# Utils - System
source "${DOCKER_LIB_DIR}/utils/system/file.sh"
source "${DOCKER_LIB_DIR}/utils/system/string.sh"

# Services
source "${DOCKER_LIB_DIR}/services/docker.sh"
source "${DOCKER_LIB_DIR}/services/firewall.sh"
source "${DOCKER_LIB_DIR}/services/permissions.sh"

# DNS
source "${DOCKER_LIB_DIR}/dns/dns-provider-select.sh"
source "${DOCKER_LIB_DIR}/dns/dns-providers-list.sh"

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