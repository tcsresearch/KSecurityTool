#!/bin/bash

PROC_PATH="/proc/sys/net/core/bpf_jit_harden"
SYSCTL_KEY="net.core.bpf_jit_harden"

# 1. Check runtime value in /proc
if [ ! -f "$PROC_PATH" ]; then
    echo "Error: BPF JIT compilation or proc entry not found on this kernel."
    exit 1
fi

RUNTIME_VAL=$(cat "$PROC_PATH")

# 2. Determine runtime security status
# 0 = Disabled (Not Secure)
# 1 = Hardening for unprivileged users only (Partially Secure)
# 2 = Hardening for all users (Fully Secure / Recommended)
if [ "$RUNTIME_VAL" -eq 2 ]; then
    RUNTIME_STATUS="SECURE (Fully hardened for all users)"
elif [ "$RUNTIME_VAL" -eq 1 ]; then
    RUNTIME_STATUS="PARTIALLY SECURE (Hardened for unprivileged users only)"
else
    RUNTIME_STATUS="NOT SECURE (Hardening disabled)"
fi

echo "--- Runtime Status ---"
echo "Current value in proc: $RUNTIME_VAL ($RUNTIME_STATUS)"

# 3. Check persistent configuration files
echo -e "\n--- Config File Status ---"

# Grab the final evaluation of sysctl configs as systemd sees them
CONFIG_VAL=$(sysctl --cat-config 2>/dev/null | grep -E -v '^(#|;)' | grep "$SYSCTL_KEY" | tail -n 1 | awk -F'=' '{print $2}' | tr -d ' ')

if [ -z "$CONFIG_VAL" ]; then
    echo "Result: NOT SECURE. No persistent setting found for '$SYSCTL_KEY' in configuration files."
    echo "Default kernel configuration will apply on reboot."
else
    if [ "$CONFIG_VAL" -eq 2 ]; then
        echo "Result: SECURE. Persistent configuration defines '$SYSCTL_KEY = 2'."
    elif [ "$CONFIG_VAL" -eq 1 ]; then
        echo "Result: PARTIALLY SECURE. Persistent configuration defines '$SYSCTL_KEY = 1'."
    else
        echo "Result: NOT SECURE. Persistent configuration explicitly disables hardening ('$SYSCTL_KEY = 0')."
    fi
fi
