#!/bin/env bash

# shellcheck source=/dev/null

function Reload-Sysctl() {
# Reload and execute the configurations immediately:
  sudo sysctl --system
}

function Reload-SysCtl_2() {
# Alternatively, you can run sudo sysctl -p /etc/sysctl.d/99-hardening.conf to target the specific file.
  sudo sysctl -p /etc/sysctl.d/99-hardening.conf
}


function CheckRunningChanges() {
# If you want to view your current runtime configuration to verify the changes took place, use the query command:
  sysctl -a | grep tcp_syncookies
}

