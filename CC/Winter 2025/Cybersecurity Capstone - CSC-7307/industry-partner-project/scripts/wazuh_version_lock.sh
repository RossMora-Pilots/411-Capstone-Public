#!/bin/bash
# wazuh_version_lock.sh — Lock or unlock Wazuh package versions
#
# Usage: sudo ./wazuh_version_lock.sh lock|unlock|status
#
# Prevents accidental Wazuh upgrades by applying package-manager holds.
# Supports both yum (RHEL/CentOS) and apt (Debian/Ubuntu) systems.
#
# Developed as part of the Industry Partner capstone project (Winter 2025)
# for Cambrian College's Postgraduate Cybersecurity Certificate.

WAZUH_PACKAGES=("wazuh-manager" "wazuh-agent" "wazuh-indexer" "wazuh-dashboard")

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

detect_pkg_manager() {
    if command -v yum &> /dev/null && command -v rpm &> /dev/null; then
        echo "yum"
    elif command -v apt-mark &> /dev/null; then
        echo "apt"
    else
        error_log "Unsupported package manager — requires yum or apt"
    fi
}

get_installed_version() {
    local pkg="$1" mgr="$2"
    case "$mgr" in
        yum) rpm -q --qf '%{VERSION}-%{RELEASE}' "$pkg" 2>/dev/null ;;
        apt) dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null ;;
    esac
}

do_lock() {
    local mgr="$1"
    log "Locking Wazuh packages..."

    for pkg in "${WAZUH_PACKAGES[@]}"; do
        local ver
        ver=$(get_installed_version "$pkg" "$mgr")
        [[ -z "$ver" ]] && continue

        case "$mgr" in
            yum)
                if ! rpm -q yum-plugin-versionlock &> /dev/null; then
                    yum install -y yum-plugin-versionlock &> /dev/null || \
                        error_log "Failed to install yum-plugin-versionlock"
                fi
                yum versionlock add "$pkg" &> /dev/null
                ;;
            apt)
                apt-mark hold "$pkg" &> /dev/null
                ;;
        esac
        log "Locked $pkg at version $ver"
    done

    log "Version lock applied"
}

do_unlock() {
    local mgr="$1"
    log "Unlocking Wazuh packages..."

    for pkg in "${WAZUH_PACKAGES[@]}"; do
        local ver
        ver=$(get_installed_version "$pkg" "$mgr")
        [[ -z "$ver" ]] && continue

        case "$mgr" in
            yum) yum versionlock delete "$pkg" &> /dev/null ;;
            apt) apt-mark unhold "$pkg" &> /dev/null ;;
        esac
        log "Unlocked $pkg (was $ver)"
    done

    log "Version lock removed"
}

do_status() {
    local mgr="$1"
    log "Wazuh package lock status:"

    for pkg in "${WAZUH_PACKAGES[@]}"; do
        local ver
        ver=$(get_installed_version "$pkg" "$mgr")
        if [[ -z "$ver" ]]; then
            echo -e "  ${YELLOW}$pkg${NC} — not installed"
            continue
        fi

        local held=false
        case "$mgr" in
            yum) yum versionlock list 2>/dev/null | grep -q "$pkg" && held=true ;;
            apt) apt-mark showhold 2>/dev/null | grep -q "^${pkg}$" && held=true ;;
        esac

        if $held; then
            echo -e "  ${GREEN}$pkg${NC} $ver — ${GREEN}LOCKED${NC}"
        else
            echo -e "  ${YELLOW}$pkg${NC} $ver — ${YELLOW}UNLOCKED${NC}"
        fi
    done
}

main() {
    [[ $EUID -ne 0 ]] && error_log "This script must be run as root"

    local action="${1:-}"
    if [[ -z "$action" || ! "$action" =~ ^(lock|unlock|status)$ ]]; then
        echo "Usage: sudo $0 lock|unlock|status"
        exit 1
    fi

    local mgr
    mgr=$(detect_pkg_manager)
    log "Detected package manager: $mgr"

    case "$action" in
        lock)   do_lock   "$mgr" ;;
        unlock) do_unlock "$mgr" ;;
        status) do_status "$mgr" ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
