#!/bin/bash

# Guard gegen mehrfaches Laden
if [ -n "${_VALIDATION_LOADED+x}" ]; then
    return 0
fi
_VALIDATION_LOADED=1

# Domain Validierung
validate_domain() {
    if [ -z "$DOMAIN" ]; then
        print_status "DOMAIN environment variable is not set" "error"
        return 1
    fi
    return 0
}

# Email Validierung
validate_email() {
    if [ -z "$CERTEMAIL" ]; then
        print_status "CERTEMAIL environment variable is not set" "error"
        return 1
    fi
    return 0
}

# Passwort Validierung
validate_password() {
    local password="$1"
    
    if [ ${#password} -lt 8 ]; then
        print_status "Password must be at least 8 characters" "error"
        return 1
    fi
    
    if ! echo "$password" | grep -q "[0-9]"; then
        print_status "Password must contain at least one number" "error"
        return 1
    fi
    
    if ! echo "$password" | grep -q "[!@#$%^&*]"; then
        print_status "Password must contain at least one special character" "error"
        return 1
    fi
    
    return 0
}

# Zentrale Validierungsfunktion
validate_input() {
    local input="$1"
    local type="$2"
    
    case "$type" in
        "domain")
            validate_domain "$input"
            ;;
        "email") 
            validate_email "$input"
            ;;
        "password")
            validate_password "$input"
            ;;
        *)
            return 0
            ;;
    esac
    
    return $?
}