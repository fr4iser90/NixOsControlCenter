#!/bin/bash

validate_domain() {
    if [ -z "$DOMAIN" ]; then
        echo -e "${ERROR} DOMAIN environment variable is not set"
        return 1
    fi
    return 0
}

validate_email() {
    if [ -z "$CERTEMAIL" ]; then
        echo -e "${ERROR} CERTEMAIL environment variable is not set"
        return 1
    fi
    return 0
}