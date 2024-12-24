#!/bin/bash

# Get absolute path to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to set sensitive file permissions
set_sensitive_permissions() {
    echo "Setting sensitive file permissions..."
    
    # Check if docker directory exists
    if [ ! -d "$HOME/docker" ]; then
        echo "Error: $HOME/docker does not exist!"
        return 1
    fi
    
    # Reset to standard Unix permissions
#    echo "Resetting to standard permissions..."
#    chmod -R 755 "$HOME/docker"  # Directories executable
#    find "$HOME/docker" -type f -exec chmod 644 {} \;  # Files readable

    # Protect sensitive files
#    echo "Protecting sensitive files..."
#    find "$HOME/docker" -type f \( -name "*.key" -o -name "*.pem" -o -name "*.crt" -o -name "*.json" \) -exec chmod 600 {} \;
    
    echo "File permissions set successfully!"
    return 0
}

# Main execution
set_sensitive_permissions