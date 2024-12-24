#!/bin/bash

# Guard against multiple inclusion
if [ -z "${_PROMPT_SH+x}" ]; then
    _PROMPT_SH=1

    # Input types as constants - EXPORTIERT für andere Scripts
    export INPUT_TYPE_NORMAL=1
    export INPUT_TYPE_SENSITIVE=2
    export INPUT_TYPE_EMAIL=3
fi

# Generic input prompt with validation
prompt_input() {
    local prompt_text="$1"
    local input_type="${2:-$INPUT_TYPE_NORMAL}"
    local value

    echo -e "${BLUE}$prompt_text${NC}"
    
    case $input_type in
        $INPUT_TYPE_SENSITIVE)
            while true; do
                echo -n "> "
                read -s value
                echo
                echo -n "Confirm > "
                read -s value2
                echo
                
                if [ "$value" == "$value2" ]; then
                    print_status "Validated" "success"
                    echo "$value"
                    return 0
                else
                    print_status "Values do not match. Please try again." "error"
                fi
            done
            ;;
            
        $INPUT_TYPE_EMAIL)
            while true; do
                echo -n "> "
                read value
                if [[ "$value" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
                    print_status "Valid email" "success"
                    echo "$value"
                    return 0
                else
                    print_status "Invalid email format. Please try again." "error"
                fi
            done
            ;;
            
        *)
            echo -n "> "
            read value
            echo "$value"
            return 0
            ;;
    esac
}

# Specialized prompts using the generic function
prompt_email() {
    local prompt_text="${1:-Enter email address}"
    prompt_input "$prompt_text" $INPUT_TYPE_EMAIL
}

prompt_password() {
    local prompt_text="${1:-Enter password}"
    prompt_input "$prompt_text" $INPUT_TYPE_SENSITIVE
}

prompt_confirmation() {
    local prompt_text="${1:-Are you sure?}"
    while true; do
        echo -e "${BLUE}$prompt_text [y/N]${NC}"
        echo -n "> "
        read -r yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) print_status "Please answer yes or no." "warning";;
        esac
    done
}