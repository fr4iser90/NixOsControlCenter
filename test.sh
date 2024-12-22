#!/usr/bin/env bash

# Hilfsfunktionen für Logging
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }

# Test für openssl Verfügbarkeit
echo "=== Testing openssl availability ==="
if nix-shell -p openssl --run "openssl version"; then
    log_success "openssl is available"
else
    log_error "openssl is not available"
    exit 1
fi

# Test für Password-Generierung
echo -e "\n=== Testing password generation ==="
random_hex=$(nix-shell -p openssl --run "openssl rand -hex 4")
echo "Generated hex: $random_hex"
default_password="P@ssw0rd-${random_hex}"
echo "Generated password: $default_password"

# Test für mkpasswd
echo -e "\n=== Testing mkpasswd availability ==="
if command -v mkpasswd >/dev/null 2>&1; then
    log_success "mkpasswd is available"
else
    echo "Installing whois package..."
    if sudo nix-env -iA nixos.whois; then
        log_success "whois package installed"
    else
        log_error "Failed to install whois package"
        exit 1
    fi
fi

# Test für Password-Hashing
echo -e "\n=== Testing password hashing ==="
test_password="TestPass123"
echo "Test password: $test_password"
hashed_password=$(echo "$test_password" | mkpasswd -m sha-512 --stdin)
echo "Hashed password: $hashed_password"

# Test für Verzeichniserstellung
echo -e "\n=== Testing directory creation ==="
test_dir="/tmp/test-password-dir"
if sudo mkdir -p "$test_dir"; then
    log_success "Directory created: $test_dir"
    sudo rm -rf "$test_dir"
else
    log_error "Failed to create directory"
    exit 1
fi

echo -e "\n=== All tests completed ==="
