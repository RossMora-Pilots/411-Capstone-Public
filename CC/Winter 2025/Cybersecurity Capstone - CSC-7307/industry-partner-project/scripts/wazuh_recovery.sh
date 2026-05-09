#!/bin/bash
# wazuh_recovery.sh — Fix common Wazuh issues including Cisco decoder XML parsing errors
#
# Usage: sudo ./wazuh_recovery.sh
#
# This script diagnoses and repairs Wazuh decoder/rule XML files that cause
# startup failures. It targets encoding issues, carriage-return corruption,
# and malformed XML in the decoder and rules directories. All files are
# backed up before any modification.
#
# Known problem files:
#   /var/ossec/ruleset/decoders/0065-cisco-ios_decoders.xml
#   /var/ossec/ruleset/rules/0075-cisco-ios_rules.xml
#
# Developed as part of the Industry Partner capstone project (Winter 2025)
# for Cambrian College's Postgraduate Cybersecurity Certificate.

WAZUH_SERVICE="wazuh-manager"
DECODER_DIR="/var/ossec/ruleset/decoders"
RULES_DIR="/var/ossec/ruleset/rules"
BACKUP_DIR="/var/ossec/ruleset/backups/$(date +'%Y%m%d_%H%M%S')"

CISCO_DECODER="0065-cisco-ios_decoders.xml"
CISCO_RULES="0075-cisco-ios_rules.xml"

# Color coding
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${2:-$GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error_log() {
    log "$1" "$RED"
    exit 1
}

preflight() {
    [[ $EUID -ne 0 ]] && error_log "This script must be run as root"

    if ! command -v xmllint &> /dev/null; then
        log "Installing xmllint..." "$YELLOW"
        yum install -y libxml2-utils &> /dev/null || \
        apt-get install -y libxml2-utils &> /dev/null || \
        error_log "Failed to install xmllint"
    fi

    [[ ! -d "$DECODER_DIR" ]] && error_log "Decoder directory not found: $DECODER_DIR"
    [[ ! -d "$RULES_DIR" ]]   && error_log "Rules directory not found: $RULES_DIR"
}

create_backup() {
    log "Creating backups in $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/decoders" "$BACKUP_DIR/rules" || \
        error_log "Failed to create backup directory"

    cp -a "$DECODER_DIR"/*.xml "$BACKUP_DIR/decoders/" 2>/dev/null
    cp -a "$RULES_DIR"/*.xml  "$BACKUP_DIR/rules/"     2>/dev/null
    log "Backup complete — $(find "$BACKUP_DIR" -type f | wc -l) files saved"
}

fix_carriage_returns() {
    local target_dir="$1"
    local label="$2"
    local fixed=0

    for xml in "$target_dir"/*.xml; do
        [[ ! -f "$xml" ]] && continue
        if grep -Plq '\r' "$xml"; then
            sed -i 's/\r$//' "$xml"
            log "Stripped CR characters from $(basename "$xml")" "$YELLOW"
            ((fixed++))
        fi
    done
    log "$label — fixed carriage returns in $fixed file(s)"
}

fix_encoding_headers() {
    local target_dir="$1"
    local label="$2"
    local fixed=0

    for xml in "$target_dir"/*.xml; do
        [[ ! -f "$xml" ]] && continue
        if head -1 "$xml" | grep -q 'encoding=' && \
           ! head -1 "$xml" | grep -q 'encoding="UTF-8"'; then
            sed -i '1s/encoding="[^"]*"/encoding="UTF-8"/' "$xml"
            log "Corrected encoding declaration in $(basename "$xml")" "$YELLOW"
            ((fixed++))
        fi
    done
    log "$label — corrected encoding headers in $fixed file(s)"
}

validate_xml_files() {
    local target_dir="$1"
    local label="$2"
    local failures=0

    for xml in "$target_dir"/*.xml; do
        [[ ! -f "$xml" ]] && continue
        if ! xmllint --noout "$xml" 2>/dev/null; then
            log "INVALID XML: $(basename "$xml")" "$RED"
            xmllint --noout "$xml" 2>&1 | head -3
            ((failures++))
        fi
    done

    if [[ $failures -gt 0 ]]; then
        log "$label — $failures file(s) still have XML errors" "$RED"
    else
        log "$label — all XML files are valid"
    fi
    return $failures
}

verify_cisco_files() {
    log "Checking Cisco-specific decoder and rule files..."

    for path in "$DECODER_DIR/$CISCO_DECODER" "$RULES_DIR/$CISCO_RULES"; do
        if [[ ! -f "$path" ]]; then
            log "Missing: $path" "$YELLOW"
            continue
        fi
        if xmllint --noout "$path" 2>/dev/null; then
            log "VALID: $(basename "$path")"
        else
            log "BROKEN: $(basename "$path") — see errors above" "$RED"
        fi
    done
}

restart_and_verify() {
    log "Restarting Wazuh to verify fixes..."
    systemctl restart "$WAZUH_SERVICE" 2>/dev/null
    sleep 5

    if systemctl is-active --quiet "$WAZUH_SERVICE"; then
        log "Wazuh started successfully after recovery"
    else
        log "Wazuh failed to start — check /var/ossec/logs/ossec.log" "$RED"
        tail -20 /var/ossec/logs/ossec.log 2>/dev/null | grep -i "error\|fail" | while read -r line; do
            log "  $line" "$RED"
        done
        return 1
    fi
}

main() {
    log "Starting Wazuh recovery..."

    preflight
    create_backup

    fix_carriage_returns "$DECODER_DIR" "Decoders"
    fix_carriage_returns "$RULES_DIR"   "Rules"

    fix_encoding_headers "$DECODER_DIR" "Decoders"
    fix_encoding_headers "$RULES_DIR"   "Rules"

    validate_xml_files "$DECODER_DIR" "Decoders"
    local dec_fail=$?
    validate_xml_files "$RULES_DIR" "Rules"
    local rule_fail=$?

    verify_cisco_files

    if [[ $dec_fail -gt 0 || $rule_fail -gt 0 ]]; then
        log "Some XML files remain invalid — manual review recommended" "$YELLOW"
    fi

    restart_and_verify
    log "Wazuh recovery complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
