{ lib, pkgs }:

let
  # Helper für ISO-Validierung
  validateIso = path: ''
    if ! ${pkgs.file}/bin/file "${path}" | grep -i "ISO 9660" > /dev/null; then
      return 1
    fi
    return 0
  '';

  # Helper für Download mit Fortschrittsanzeige
  downloadWithProgress = ''
    download_with_progress() {
      local url="$1"
      local output="$2"
      echo "  Debug: Downloading from URL: $url"  # Debug-Ausgabe
      ${pkgs.wget}/bin/wget \
        --progress=bar:force \
        --no-verbose \
        -O "$output" \
        "$url"
      return $?
    }
  '';

in {
  # Exportierte Funktionen
  isoManager = { name, url, stateDir, distroName, variant ? null, version ? null }: ''
    function manage_iso() {
      local iso_dir="${stateDir}/testing/iso"
      local iso_name="${name}.iso"
      local iso_path="$iso_dir/$iso_name"
      
      function validate_iso() {
        local path="$1"
        ${validateIso "$1"}
      }

      if [ -f "$iso_path" ]; then
        echo "Validating existing ISO..." >&2
        if ! validate_iso "$iso_path"; then
          echo "❌ Existing ISO is corrupt, re-downloading..." >&2
          rm -f "$iso_path"
        else
          printf '%s' "$iso_path"
          return 0
        fi
      fi
      
      mkdir -p "$iso_dir"
      echo "📥 Downloading $distroName ISO..." >&2
      ${pkgs.wget}/bin/wget \
        --progress=bar:force \
        --show-progress \
        -O "$iso_path" \
        "${toString url}" >&2
        
      echo "Validating downloaded ISO..." >&2
      if ! validate_iso "$iso_path"; then
        echo "❌ Downloaded ISO is corrupt!" >&2
        rm -f "$iso_path"
        return 1
      fi

      printf '%s' "$iso_path"
      return 0
    }
    manage_iso
  '';
}