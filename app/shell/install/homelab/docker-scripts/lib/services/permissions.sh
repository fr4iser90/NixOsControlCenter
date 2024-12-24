#!/bin/bash

# Set standard permissions for files and directories
set_standard_permissions() {
    local target_dir="$1"
    echo -e "${INFO} Setting permissions for ${BLUE}${target_dir}${NC}"

    # Set base permissions
    find "$target_dir" -type d -exec chmod 755 {} \;
    find "$target_dir" -type f -exec chmod 644 {} \;

    # Make scripts executable
    find "$target_dir" -type f -name "*.sh" -exec chmod +x {} \;
}

# Set ownership for files and directories
set_ownership() {
    local target_dir="$1"
    local owner="$2"
    echo -e "${INFO} Setting ownership for ${BLUE}${target_dir}${NC} to ${YELLOW}${owner}${NC}"

    chown -R "$owner:$owner" "$target_dir"
}

# Main function to set all permissions
setup_permissions() {
    echo -e "${INFO} Setting up file permissions..."

    # Set permissions for both directories
    set_standard_permissions "$DOCKER_BASE_DIR"
    set_standard_permissions "$DOCKER_SCRIPT_DIR"

    # Set ownership if VIRT_USER is defined
    if [ -n "$VIRT_USER" ]; then
        set_ownership "$DOCKER_BASE_DIR" "$VIRT_USER"
        set_ownership "$DOCKER_SCRIPT_DIR" "$VIRT_USER"
        echo -e "${SUCCESS} File permissions and ownership set successfully!"
    else
        echo -e "${WARNING} VIRT_USER not defined, skipping ownership setup"
    fi
}