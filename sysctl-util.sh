#!/bin/env bash

# shellcheck source=/dev/null

function Reload_Sysctl() {
# Reload and execute the configurations immediately:
  sudo sysctl --system
}

function Reload_SysCtl_2() {
# Alternatively, you can run sudo sysctl -p /etc/sysctl.d/99-hardening.conf to target the specific file.
  sudo sysctl -p /etc/sysctl.d/99-hardening.conf
}


function CheckRunningChanges() {
# If you want to view your current runtime configuration to verify the changes took place, use the query command:
  sysctl -a | grep tcp_syncookies
}




# Usage function explaining how to run the script and what options are available
usage() {
    echo "Usage: $(basename "$0") [option]"
    echo ""
    echo "Options:"
    echo "  -r, --reload        Reload and execute the configurations immediately."
    echo "  -e, --reload2       Reload and execute the configurations immediately (Alternate Method)."
    echo "  -c, --check         View your current runtime configuration to verify the changes took place."
    echo "  -h, --help          Display this help message."
    echo ""
    echo "Example:"
    echo "  $(basename "$0") --reload"
    return 1
}

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    usage
fi

# Parse command-line arguments using a case statement
case "$1" in
    -r|--reload)
        Reload_Sysctl
        ;;
    -e|--reload2)
        Reload_Sysctl_2
        ;;
    -c|--check)
        CheckRunningChanges
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo "Error: Invalid option '$1'"
        echo ""
        usage
        ;;
esac
