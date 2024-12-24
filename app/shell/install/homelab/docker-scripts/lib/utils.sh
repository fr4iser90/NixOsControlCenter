#!/bin/bash

# Common utility functions for string generation and manipulation
generate_random_string() {
    nix-shell -p openssl --run "openssl rand -base64 ${1:-32}"
}

escape_for_sed() {
    echo "$1" | sed -e 's/[\/&]/\\&/g'
}

# Password handling functions
prompt_password() {
    local prompt_text="${1:-Enter password}"
    while true; do
        read -sp "$prompt_text: " password1
        echo
        read -sp "Confirm password: " password2
        echo
        if [ "$password1" == "$password2" ]; then
            echo "$password1"
            return
        else
            echo "Passwords do not match. Please try again."
        fi
    done
}

# User information functions
get_user_info() {
    USER_UID=$(id -u)
    USER_GID=$(id -g)
}

# File handling functions
update_env_file() {
    local base_dir=$1
    local env_file=$2
    shift 2
    local new_values=("$@")

    if [ -f "$base_dir/$env_file" ]; then
        echo "Updating $env_file"
        for entry in "${new_values[@]}"; do
            local key="${entry%%:*}"
            local value="${entry#*:}"
            sed -i "s|^$key=.*|$key=$value|" "$base_dir/$env_file"
        done
    else
        echo "File $base_dir/$env_file does not exist" >&2
        return 1
    fi
}

update_compose_file() {
    local base_dir=$1
    local compose_file=$2
    local uid=$3
    local gid=$4

    if [ -f "$base_dir/$compose_file" ]; then
        echo "Updating $compose_file with UID=$uid and GID=$gid"
        sed -i "s|PUID=[0-9]*|PUID=$uid|" "$base_dir/$compose_file"
        sed -i "s|PGID=[0-9]*|PGID=$gid|" "$base_dir/$compose_file"
        sed -i "s|PUID: '[0-9]*'|PUID: '$uid'|" "$base_dir/$compose_file"
        sed -i "s|PGID: '[0-9]*'|PGID: '$gid'|" "$base_dir/$compose_file"
    else
        echo "File $base_dir/$compose_file does not exist" >&2
        return 1
    fi
}

# Domain validation
validate_domain() {
    if [ -z "$DOMAIN" ]; then
        echo "DOMAIN environment variable is not set" >&2
        return 1
    fi
    return 0
}

# Hashing functions
generate_salt() {
    generate_random_string 16
}

hash_password() {
    local password=$1
    local salt=$(generate_salt)
    nix-shell -p libargon2 --run "echo -n '$password' | argon2 '$salt' -id -t 2 -m 16 -p 1" | grep -Eo '\$argon2id\$[^\s]+'
}

# Docker container management functions
start_docker_container() {
    local container=$1
    local category=$(get_container_category "$container")
    local docker_dir=$(get_docker_dir "$container")

    if [ -z "$docker_dir" ]; then
        return 1
    fi

    # Check if updateEnv.sh exists and execute it
    if [ -f "$docker_dir/updateEnv.sh" ]; then
        echo "Executing updateEnv.sh in $container"
        (cd "$docker_dir" && bash updateEnv.sh)
    fi

    if [ -d "$docker_dir" ]; then
        echo "Starting docker-compose in $category/$container"
        (cd "$docker_dir" && docker compose up -d)
    else
        echo "Directory $category/$container does not exist" >&2
        return 1
    fi
}

restart_docker_container() {
    local container=$1
    local category=$(get_container_category "$container")
    local docker_dir=$(get_docker_dir "$container")

    if [ -z "$docker_dir" ]; then
        return 1
    fi

    if [ -d "$docker_dir" ]; then
        echo "Restarting docker-compose in $category/$container"
        (cd "$docker_dir" && docker compose up -d --force-recreate)
    else
        echo "Directory $category/$container does not exist" >&2
        return 1
    fi
}

# Email validation
validate_email() {
    if [ -z "$CERTEMAIL" ]; then
        echo "CERTEMAIL environment variable is not set" >&2
        return 1
    fi
    return 0
}