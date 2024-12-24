#!/bin/bash

start_docker_container() {
    local container=$1
    local docker_dir=$(get_docker_dir "$container")

    if [ -z "$docker_dir" ]; then
        echo -e "${ERROR} Invalid container: $container"
        return 1
    fi

    echo -e "${INFO} Starting ${BLUE}$container${NC}"

    # Check for update-env.sh
    if [ -f "$docker_dir/update-env.sh" ]; then
        echo -e "${INFO} Running environment updates..."
        (cd "$docker_dir" && bash update-env.sh)
    fi

    if [ -d "$docker_dir" ]; then
        (cd "$docker_dir" && docker compose up -d)
        echo -e "${SUCCESS} Container started successfully"
        return 0
    else
        echo -e "${ERROR} Container directory not found"
        return 1
    fi
}

restart_docker_container() {
    local container=$1
    local docker_dir=$(get_docker_dir "$container")

    if [ -z "$docker_dir" ]; then
        echo -e "${ERROR} Invalid container: $container"
        return 1
    fi

    if [ -d "$docker_dir" ]; then
        echo -e "${INFO} Restarting ${BLUE}$container${NC}"
        (cd "$docker_dir" && docker compose up -d --force-recreate)
        echo -e "${SUCCESS} Container restarted successfully"
        return 0
    else
        echo -e "${ERROR} Container directory not found"
        return 1
    fi
}