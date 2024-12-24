#!/bin/bash

# Guard gegen mehrfaches Laden
if [ -n "${_DNS_PROVIDER_SELECT_LOADED+x}" ]; then
    return 0
fi
_DNS_PROVIDER_SELECT_LOADED=1

# ==============================================
# DNS Provider Selection Functions
# ==============================================

select_dns_provider() {
    # Prüfen ob providers Array existiert
    if [ -z "${providers[*]}" ]; then
        print_status "DNS provider list not loaded" "error"
        return 1
    fi

    print_status "Select DNS provider:" "info"
    
    # Erstelle temporäre Datei für die Provider-Liste
    local tmp_file=$(mktemp)
    printf "%s\n" "${providers[@]}" > "$tmp_file"

    # Nutze FZF mit besseren Optionen
    local selected_provider=$(cat "$tmp_file" | \
        fzf --height=80% \
            --layout=reverse \
            --border=rounded \
            --prompt="DNS Provider > " \
            --header="Use arrows or type to search, Enter to select" \
            --preview 'echo {} | cut -d" " -f1' \
            --preview-window=up:1 \
            --no-multi)

    # Cleanup
    rm "$tmp_file"

    if [ -z "$selected_provider" ]; then
        print_status "No provider selected" "error"
        return 1
    fi

    echo "$selected_provider"
}

# Get DNS credentials
get_dns_credentials() {
    local selected_provider="$1"
    
    # Split provider info - nimm alles nach dem zweiten Feld
    local provider_name=$(echo "$selected_provider" | cut -d' ' -f1)
    local provider_code=$(echo "$selected_provider" | cut -d' ' -f2)
    local provider_vars=$(echo "$selected_provider" | cut -d' ' -f3-)
    
    print_status "Configuring credentials for $provider_name" "info"
    
    # Exportiere Provider-Info
    export DNS_PROVIDER_NAME="$provider_name"
    export DNS_PROVIDER_CODE="$provider_code"
    
    # Get credentials for each variable
    for var in $provider_vars; do
        print_status "Setting up $var..." "info"
        
        # Bestimme Input-Typ basierend auf Variablenname
        local input_type="$INPUT_TYPE_NORMAL"
        if [[ "$var" =~ .*(PASSWORD|SECRET|KEY|TOKEN).* ]]; then
            input_type="$INPUT_TYPE_SENSITIVE"
        fi
        
        # Frage nach dem Wert
        local value=""
        if [ "$input_type" = "$INPUT_TYPE_SENSITIVE" ]; then
            value=$(prompt_password "Enter $var")
        else
            value=$(prompt_input "Enter $var" "$input_type")
        fi
        
        # Zeige den eingegebenen Wert entsprechend der Einstellung
        display_credential "$value" "$var"
        
        # Exportiere als Umgebungsvariable
        export "$var=$value"
    done
    
    print_status "Credentials configured for $provider_name" "success"
    return 0
}