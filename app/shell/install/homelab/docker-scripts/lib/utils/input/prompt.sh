#!/bin/bash

# Zuerst die benötigten Funktionen laden
source "${DOCKER_LIB_DIR}/utils/format/output.sh"

# Guard against multiple inclusion
if [ -z "${_PROMPT_SH+x}" ]; then
    _PROMPT_SH=1

    # Input types as constants - EXPORTIERT für andere Scripts
    export INPUT_TYPE_NORMAL=1
    export INPUT_TYPE_SENSITIVE=2
    export INPUT_TYPE_EMAIL=3
    export INPUT_TYPE_USERNAME=4
    export INPUT_TYPE_PASSWORD=5
fi

print_prompt() {
    local message="$1"
    echo -e "\n${BLUE}==================================================
        $message        
==================================================${NC}\n"
}

# Generic input prompt with validation
prompt_input() {
    local prompt_text="$1"
    local input_type="${2:-$INPUT_TYPE_NORMAL}"
    local value

    # DEBUG
    echo "DEBUG: prompt_input called with text='$prompt_text' type='$input_type'" >&2

    case $input_type in
        $INPUT_TYPE_USERNAME)
            echo "DEBUG: Handling USERNAME input" >&2
            while true; do
                echo -en "${BLUE}Username${NC} > " > /dev/tty
                read value < /dev/tty
                echo "DEBUG: Got username='$value'" >&2
                if [ -n "$value" ]; then
                    echo "$value"
                    return 0
                fi
                print_status "Username cannot be empty" "error"
            done
            ;;
            
        $INPUT_TYPE_PASSWORD|$INPUT_TYPE_SENSITIVE)
            echo "DEBUG: Handling PASSWORD input" >&2
            while true; do
                echo -en "${BLUE}Password${NC} > " > /dev/tty
                read -s value < /dev/tty
                echo
                echo "DEBUG: Got password length=${#value}" >&2
                
                if [[ ${#value} -lt 8 ]]; then
                    print_status "Password must be at least 8 characters" "error"
                    continue
                fi
                if ! [[ $value =~ [0-9] ]]; then
                    print_status "Password must contain at least one number" "error"
                    continue
                fi
                if ! [[ $value =~ [^a-zA-Z0-9] ]]; then
                    print_status "Password must contain at least one special character" "error"
                    continue
                fi

                printf "${BLUE}Confirm${NC} > "
                read -s value2
                echo
                
                if [ "$value" == "$value2" ]; then
                    print_status "Password validated" "success"
                    echo "$value"
                    return 0
                else
                    print_status "Passwords do not match" "error"
                fi
            done
            ;;
            
        $INPUT_TYPE_EMAIL)
            while true; do
                printf "${BLUE}Email${NC} > "
                read value
                if [[ "$value" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
                    echo "$value"
                    return 0
                else
                    echo "Invalid email format. Please try again."
                fi
            done
            ;;
            
        *)
            printf "${BLUE}%s${NC} > " "$prompt_text"
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
    prompt_input "$prompt_text" $INPUT_TYPE_PASSWORD
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
            * ) echo "Please answer yes or no."
        esac
    done
}
