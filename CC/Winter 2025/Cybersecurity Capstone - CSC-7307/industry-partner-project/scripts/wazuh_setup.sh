#!/bin/bash
# wazuh_setup.sh — Configure and validate Wazuh for receiving syslog messages
#
# Usage: sudo ./wazuh_setup.sh
#
# This script performs a complete Wazuh syslog integration setup including
# pre-flight checks, configuration injection, XML validation, service restart,
# and post-deployment verification. It automatically rolls back on failure.
#
# Developed as part of the Industry Partner capstone project (Winter 2025)
# for Cambrian College's Postgraduate Cybersecurity Certificate.

# Configuration
WAZUH_IP="192.168.80.2"
RSYSLOG_IP="192.168.93.60"
SYSLOG_PORT="514"
SYSLOG_PROTOCOL="udp"
OSSEC_CONF="/var/ossec/etc/ossec.conf"
WAZUH_SERVICE="wazuh-manager"

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

precheck_wazuh() {
    log "Starting pre-checks..."

    [[ $EUID -ne 0 ]] && error_log "This script must be run as root"

    if ! command -v xmllint &> /dev/null; then
        log "Installing xmllint..." "$YELLOW"
        yum install -y libxml2-utils &> /dev/null || \
        apt-get install -y libxml2-utils &> /dev/null || \
        error_log "Failed to install xmllint"
    fi

    systemctl list-unit-files | grep -q wazuh-manager || \
        error_log "Wazuh manager service not found"
    systemctl is-active --quiet $WAZUH_SERVICE || \
        error_log "Wazuh service is not running"

    [[ ! -f "$OSSEC_CONF" ]] && error_log "ossec.conf not found at $OSSEC_CONF"
    [[ ! -w "$OSSEC_CONF" ]] && error_log "ossec.conf is not writable"

    ping -c 1 -W 1 $RSYSLOG_IP &> /dev/null || \
        log "Cannot ping Rsyslog server ($RSYSLOG_IP) - firewall might block ICMP" "$YELLOW"

    if netstat -tuln | grep ":$SYSLOG_PORT " &> /dev/null; then
        if netstat -tulnp | grep ":$SYSLOG_PORT" | grep -q "wazuh"; then
            log "Port $SYSLOG_PORT is already being used by Wazuh"
        else
            error_log "Port $SYSLOG_PORT is being used by another service"
        fi
    fi

    log "Pre-checks completed successfully"
}

configure_wazuh() {
    log "Configuring Wazuh..."

    local backup_file="${OSSEC_CONF}.backup.$(date +'%Y%m%d_%H%M%S')"
    cp "$OSSEC_CONF" "$backup_file" || error_log "Failed to create backup"
    log "Configuration backed up to $backup_file"

    local temp_conf
    temp_conf=$(mktemp)
    cp "$OSSEC_CONF" "$temp_conf" || error_log "Failed to create temporary configuration"

    if ! grep -q "<ossec_config>" "$temp_conf"; then
        error_log "Invalid ossec.conf format - missing <ossec_config>"
    fi

    sed -i '/<syslog>/,/<\/syslog>/d' "$temp_conf"

    local insert_point
    if grep -q "</global>" "$temp_conf"; then
        insert_point="</global>"
    else
        insert_point="</ossec_config>"
    fi

    local syslog_config="
  <!-- Syslog configuration for Rsyslog integration -->
  <syslog>
    <port>$SYSLOG_PORT</port>
    <protocol>$SYSLOG_PROTOCOL</protocol>
    <allowed-ips>$RSYSLOG_IP</allowed-ips>
  </syslog>"

    sed -i "/$insert_point/i\\$syslog_config" "$temp_conf"

    if ! xmllint --noout "$temp_conf" 2>/dev/null; then
        log "XML validation failed. Checking specific issues..." "$RED"
        xmllint --noout "$temp_conf"
        mv "$backup_file" "$OSSEC_CONF"
        rm "$temp_conf"
        error_log "XML syntax validation failed - reverting to backup"
    fi

    mv "$temp_conf" "$OSSEC_CONF" || error_log "Failed to apply new configuration"
    chown root:wazuh "$OSSEC_CONF"
    chmod 640 "$OSSEC_CONF"

    if ! /var/ossec/bin/wazuh-control validate &>/dev/null; then
        mv "$backup_file" "$OSSEC_CONF"
        error_log "Wazuh configuration validation failed - reverting to backup"
    fi

    log "Configuration updated successfully"

    systemctl restart $WAZUH_SERVICE || error_log "Failed to restart Wazuh service"
    sleep 5
    log "Wazuh configuration completed and service restarted"
}

postcheck_wazuh() {
    log "Starting post-configuration checks..."

    systemctl is-active --quiet $WAZUH_SERVICE || \
        error_log "Wazuh service failed to start after configuration"

    if ! netstat -tuln | grep ":$SYSLOG_PORT " &> /dev/null; then
        error_log "Syslog port $SYSLOG_PORT is not listening"
    fi

    ps aux | grep [o]ssec-logcollector | grep -q root || \
        log "Warning: Wazuh processes not running as root" "$YELLOW"

    if grep -i "error\|failed" /var/ossec/logs/ossec.log | tail -n 5; then
        log "Warning: Found potential errors in Wazuh logs" "$YELLOW"
    fi

    timeout 5 nc -uz localhost $SYSLOG_PORT &>/dev/null || \
        log "Warning: Cannot connect to syslog port locally" "$YELLOW"

    log "Post-configuration checks completed"
}

monitor_wazuh() {
    log "Starting Wazuh logs monitoring (30 seconds)..."

    (timeout 30 tail -f /var/ossec/logs/ossec.log | \
        grep --line-buffered -i "syslog\|cisco" &)
    (timeout 30 tail -f /var/ossec/logs/alerts/alerts.log | \
        grep --line-buffered -i "syslog\|cisco" &)

    sleep 30
    log "Monitoring completed"
}

cleanup() {
    log "Performing cleanup..."
    pkill -f "tail -f /var/ossec/logs/ossec.log" 2>/dev/null
    pkill -f "tail -f /var/ossec/logs/alerts/alerts.log" 2>/dev/null
}

main() {
    trap cleanup EXIT

    log "Starting Wazuh setup and configuration..."

    precheck_wazuh
    configure_wazuh
    postcheck_wazuh
    monitor_wazuh

    log "Wazuh setup completed successfully"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
