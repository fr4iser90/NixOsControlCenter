# modules/system-management/preflight/runners/cli.nix
{ config, lib, pkgs, ... }:

let
  inherit (lib) types;

  # Validierungs-Script
  validateResult = pkgs.writeScript "validate-result" ''
    #!${pkgs.bash}/bin/bash
    RESULT="$1"
    VALIDATION="$2"
    
    # Führe die Validierung durch
    if [ -n "$VALIDATION" ]; then
      eval "$VALIDATION '$RESULT'"
    else
      # Standard-Validierung: Prüfe auf Exit-Code 0
      if [ "$RESULT" = "0" ]; then
        echo '{"success":true,"message":"Check passed"}'
      else
        echo '{"success":false,"message":"Check failed"}'
      fi
    fi
  '';

  # Check-Runner Funktion
  runCheck = name: check: ''
    echo "Running ${name}..."
    if [ -x "${check}/bin/${name}" ]; then
      RESULT=$(${check}/bin/${name} 2>&1)
      EXIT_CODE=$?
      
      # Validiere das Ergebnis
      VALIDATION=$(${validateResult} "$EXIT_CODE" "${check.validate or ""}")
      
      if [ "$(echo "$VALIDATION" | ${pkgs.jq}/bin/jq -r .success)" = "true" ]; then
        echo "✓ ${name}: $(echo "$VALIDATION" | ${pkgs.jq}/bin/jq -r .message)"
      else
        echo "✗ ${name}: $(echo "$VALIDATION" | ${pkgs.jq}/bin/jq -r .message)"
        FAILED=1
      fi
    else
      echo "! ${name}: Check not executable"
      FAILED=1
    fi
  '';

  # Haupt-Runner Script
  checkRunner = pkgs.writeScriptBin "run-system.preflight.checks" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    FAILED=0

    echo "Running system preflight checks..."
    
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList runCheck config.system.preflight.checks)}
    
    if [ "$FAILED" -eq 1 ]; then
      echo "Some checks failed. Please review the messages above."
      exit 1
    fi
    
    echo "All checks passed successfully!"
    exit 0
  '';

in {
  options.system.preflight.checks = lib.mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        check = lib.mkOption {
          type = types.package;
          description = "The check script to run";
        };
        validate = lib.mkOption {
          type = types.str;
          default = "";
          description = "Optional validation command";
        };
      };
    });
    default = {};
    description = "Set of system.preflight.checks to run";
  };

  config = lib.mkIf config.system.management.enablePreflight {
    environment.systemPackages = [ checkRunner ];
  };
}