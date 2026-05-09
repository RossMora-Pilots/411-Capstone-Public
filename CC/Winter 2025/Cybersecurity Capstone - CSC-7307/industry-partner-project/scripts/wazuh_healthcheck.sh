#!/bin/bash
# wazuh_healthcheck.sh — Comprehensive Wazuh health verification
#
# Usage: sudo ./wazuh_healthcheck.sh
#
# Performs a full diagnostic sweep of a Wazuh manager installation and prints
# a summary table with PASS / WARN / FAIL for every check. Designed for use
# in routine maintenance or after configuration changes.
#
# Checks performed:
#   1. Service status (wazuh-manager)
#   2. Port listening (514/UDP, 1514/TCP, 1515/TCP, 55000/TCP)
#   3. Disk usage on /var/ossec
#   4. Log file sizes
#   5. Recent errors in ossec.log
#   6. Agent connection status
#   7. Wazuh indexer status
#   8. Wazuh version verification
#   9. Configuration validation (ossec.conf)
#
# Developed as part of the Industry Partner capstone project (Winter 2025)
# for Cambrian College's Postgraduate Cybersecurity Certificate.

WAZUH_SERVICE="wazuh-manager"
OSSEC_DIR="/var/ossec"
OSSEC_CONF="$OSSEC_DIR/etc/ossec.conf"
OSSEC_LOG="$OSSEC_DIR/logs/ossec.log"
DISK_WARN_PCT=80
DISK_FAIL_PCT=95
LOG_WARN_MB=500
ERROR_THRESHOLD=10

# Color coding
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

log() {
    echo -e "${2:-$GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error_log() {
    log "$1" "$RED"
    exit 1
}

record() {
    local status="$1" label="$2" detail="$3"
    case "$status" in
        PASS) echo -e "  ${GREEN}[PASS]${NC} $label — $detail"; ((PASS++)) ;;
        WARN) echo -e "  ${YELLOW}[WARN]${NC} $label — $detail"; ((WARN++)) ;;
        FAIL) echo -e "  ${RED}[FAIL]${NC} $label — $detail"; ((FAIL++)) ;;
    esac
}

check_service() {
    if systemctl is-active --quiet "$WAZUH_SERVICE" 2>/dev/null; then
        record PASS "Service status" "$WAZUH_SERVICE is running"
    else
        record FAIL "Service status" "$WAZUH_SERVICE is not running"
    fi
}

check_ports() {
    local -A ports=( [514]="udp" [1514]="tcp" [1515]="tcp" [55000]="tcp" )

    for port in "${!ports[@]}"; do
        local proto="${ports[$port]}"
        if ss -lnp 2>/dev/null | grep -q "${proto}.*:${port} "; then
            record PASS "Port $port/$proto" "listening"
        else
            record FAIL "Port $port/$proto" "not listening"
        fi
    done
}

check_disk() {
    if [[ ! -d "$OSSEC_DIR" ]]; then
        record FAIL "Disk usage" "$OSSEC_DIR does not exist"
        return
    fi
    local usage
    usage=$(df "$OSSEC_DIR" | awk 'NR==2 {gsub(/%/,""); print $5}')
    if [[ $usage -ge $DISK_FAIL_PCT ]]; then
        record FAIL "Disk usage" "${usage}% used on $OSSEC_DIR"
    elif [[ $usage -ge $DISK_WARN_PCT ]]; then
        record WARN "Disk usage" "${usage}% used on $OSSEC_DIR"
    else
        record PASS "Disk usage" "${usage}% used on $OSSEC_DIR"
    fi
}

check_log_sizes() {
    if [[ ! -f "$OSSEC_LOG" ]]; then
        record WARN "Log file" "ossec.log not found"
        return
    fi
    local size_mb
    size_mb=$(du -m "$OSSEC_LOG" 2>/dev/null | awk '{print $1}')
    if [[ $size_mb -ge $LOG_WARN_MB ]]; then
        record WARN "Log file size" "ossec.log is ${size_mb} MB — consider rotation"
    else
        record PASS "Log file size" "ossec.log is ${size_mb} MB"
    fi
}

check_recent_errors() {
    if [[ ! -f "$OSSEC_LOG" ]]; then
        record WARN "Recent errors" "ossec.log not found"
        return
    fi
    local count
    count=$(tail -500 "$OSSEC_LOG" | grep -ci "error\|critical")
    if [[ $count -ge $ERROR_THRESHOLD ]]; then
        record FAIL "Recent errors" "$count error(s) in last 500 log lines"
    elif [[ $count -gt 0 ]]; then
        record WARN "Recent errors" "$count error(s) in last 500 log lines"
    else
        record PASS "Recent errors" "no errors in last 500 log lines"
    fi
}

check_agents() {
    if [[ ! -x "$OSSEC_DIR/bin/agent_control" ]]; then
        record WARN "Agent status" "agent_control binary not found"
        return
    fi
    local total active disconnected
    total=$("$OSSEC_DIR/bin/agent_control" -l 2>/dev/null | grep -c "ID:")
    active=$("$OSSEC_DIR/bin/agent_control" -l 2>/dev/null | grep -c "Active")
    disconnected=$(( total - active ))
    if [[ $disconnected -gt 0 ]]; then
        record WARN "Agent status" "$active/$total agents active ($disconnected disconnected)"
    else
        record PASS "Agent status" "$active/$total agents active"
    fi
}

check_indexer() {
    if curl -sk -o /dev/null -w "%{http_code}" https://localhost:9200/ 2>/dev/null | grep -q "200\|401"; then
        record PASS "Indexer" "Wazuh indexer is reachable on port 9200"
    else
        record WARN "Indexer" "Wazuh indexer not reachable on port 9200"
    fi
}

check_version() {
    if [[ -x "$OSSEC_DIR/bin/wazuh-control" ]]; then
        local ver
        ver=$("$OSSEC_DIR/bin/wazuh-control" info -v 2>/dev/null)
        if [[ -n "$ver" ]]; then
            record PASS "Wazuh version" "$ver"
        else
            record WARN "Wazuh version" "unable to determine version"
        fi
    else
        record FAIL "Wazuh version" "wazuh-control binary not found"
    fi
}

check_config() {
    if [[ ! -f "$OSSEC_CONF" ]]; then
        record FAIL "Config validation" "ossec.conf not found"
        return
    fi

    if command -v xmllint &> /dev/null; then
        if xmllint --noout "$OSSEC_CONF" 2>/dev/null; then
            record PASS "Config validation" "ossec.conf XML is well-formed"
        else
            record FAIL "Config validation" "ossec.conf has XML syntax errors"
        fi
    elif [[ -x "$OSSEC_DIR/bin/wazuh-control" ]]; then
        if "$OSSEC_DIR/bin/wazuh-control" validate &>/dev/null; then
            record PASS "Config validation" "ossec.conf passed wazuh-control validate"
        else
            record FAIL "Config validation" "ossec.conf failed wazuh-control validate"
        fi
    else
        record WARN "Config validation" "no validator available (install xmllint)"
    fi
}

main() {
    [[ $EUID -ne 0 ]] && error_log "This script must be run as root"

    log "Starting Wazuh health check..."
    echo ""

    check_service
    check_ports
    check_disk
    check_log_sizes
    check_recent_errors
    check_agents
    check_indexer
    check_version
    check_config

    echo ""
    echo -e "  ────────────────────────────────"
    echo -e "  ${GREEN}PASS: $PASS${NC}  ${YELLOW}WARN: $WARN${NC}  ${RED}FAIL: $FAIL${NC}"
    echo -e "  ────────────────────────────────"
    echo ""

    if [[ $FAIL -gt 0 ]]; then
        log "Health check finished with failures — review items above" "$RED"
        exit 1
    elif [[ $WARN -gt 0 ]]; then
        log "Health check finished with warnings" "$YELLOW"
    else
        log "All health checks passed"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
