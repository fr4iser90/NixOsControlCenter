#!/bin/bash

update_env_file() {
    local base_dir=$1
    local env_file=$2
    shift 2
    local new_values=("$@")

    if [ -f "$base_dir/$env_file" ]; then
        echo -e "${INFO} Updating ${BLUE}$env_file${NC}"
        for entry in "${new_values[@]}"; do
            local key="${entry%%:*}"
            local value="${entry#*:}"
            sed -i "s|^$key=.*|$key=$value|" "$base_dir/$env_file"
        done
        return 0
    else
        echo -e "${ERROR} File $base_dir/$env_file does not exist"
        return 1
    fi
}

update_compose_file() {
    local base_dir=$1
    local compose_file=$2
    local uid=$3
    local gid=$4

    if [ -f "$base_dir/$compose_file" ]; then
        echo -e "${INFO} Updating ${BLUE}$compose_file${NC} with UID=$uid and GID=$gid"
        sed -i "s|PUID=[0-9]*|PUID=$uid|" "$base_dir/$compose_file"
        sed -i "s|PGID=[0-9]*|PGID=$gid|" "$base_dir/$compose_file"
        sed -i "s|PUID: '[0-9]*'|PUID: '$uid'|" "$base_dir/$compose_file"
        sed -i "s|PGID: '[0-9]*'|PGID: '$gid'|" "$base_dir/$compose_file"
        return 0
    else
        echo -e "${ERROR} File $base_dir/$compose_file does not exist"
        return 1
    fi
}