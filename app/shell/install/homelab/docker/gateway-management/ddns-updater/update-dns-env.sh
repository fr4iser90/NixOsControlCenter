#!/bin/bash

update_dns_env() {
  local provider_code="$1"
  shift
  local vars=("$@")

  if [ -f "$BASE_DIR/$ENV_FILE" ]; then
    echo "Updating $ENV_FILE in traefik with $provider_code variables"
    for var in "${vars[@]}"; do
      read -s -p "Enter value for $var: " value
      echo # Add newline after hidden input
      sed -i "/^$var=/d" "$BASE_DIR/$ENV_FILE"
      echo "$var=$value" >> "$BASE_DIR/$ENV_FILE"
      echo "[OK] $var=********"
    done
  else
    echo "File $BASE_DIR/$ENV_FILE does not exist" >&2
    exit 1
  fi
}