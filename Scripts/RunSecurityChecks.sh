#!/bin/env bash

###########################################################################################################################################
# Check_bpf_jit_harden.sh #                                                                                                               #
###########################################################################################################################################

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

###########################################################################################################################################
# Check_kptr_restrict.sh #                                                                                                                #
###########################################################################################################################################

# Configuration and target definitions
CONFIG_FILE="conf/kptr_restrict.conf"
PROC_FILE="/proc/sys/kernel/kptr_restrict"

# 1. Verify the /proc entry exists
if [ ! -f "$PROC_FILE" ]; then
    echo "Error: $PROC_FILE not found. Is this a Linux system?"
    exit 2
fi

# 2. Verify and parse the configuration file
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' missing."
    exit 2
fi

# Safely extract expected value using grep/awk instead of sourcing the file
EXPECTED_VALUE=$(grep -E '^kernel\.kptr_restrict[[:space:]]*=' "$CONFIG_FILE" | awk -F'=' '{print $2}' | tr -d '[:space:]')

if [ -z "$EXPECTED_VALUE" ]; then
    echo "Error: 'kernel.kptr_restrict' not defined in $CONFIG_FILE."
    exit 2
fi

# 3. Read the live system state
CURRENT_VALUE=$(cat "$PROC_FILE")

# 4. Evaluate compliance and determine if secure
# Note: Security standards usually dictate a value of '1' or '2'
if [ "$CURRENT_VALUE" -eq "$EXPECTED_VALUE" ]; then
    if [ "$CURRENT_VALUE" -gt 0 ]; then
        echo "Secure"
        exit 0
    else
        echo "Not Secure (System matches config, but kptr_restrict is disabled [0])"
        exit 1
    fi
else
    echo "Not Secure (System value '$CURRENT_VALUE' does not match config target '$EXPECTED_VALUE')"
    exit 1
fi

###########################################################################################################################################
# Check_ptrace_scope.sh #                                                                                                                 #
###########################################################################################################################################

# Paths
PROC_FILE="/proc/sys/kernel/yama/ptrace_scope"
CONFIG_FILE="conf/ptrace.conf"

# Ensure proc file exists (Yama LSM must be enabled)
if [ ! -f "$PROC_FILE" ]; then
    echo "ERROR: $PROC_FILE not found. Yama security module might be disabled."
    exit 1
fi

# Ensure config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file '$CONFIG_FILE' missing."
    exit 1
fi

# 1. Read current runtime value from /proc
current_value=$(cat "$PROC_FILE")

# 2. Source the config file to read minimum secure threshold
# Expected format inside ptrace.conf: MIN_SECURE_LEVEL=1
source "$CONFIG_FILE"

if [ -z "$MIN_SECURE_LEVEL" ]; then
    echo "ERROR: MIN_SECURE_LEVEL is not defined in $CONFIG_FILE"
    exit 1
fi

# 3. Evaluate and return result
echo "--- PTRACE SCOPE STATUS ---"
echo "Current Runtime Value: $current_value"
echo "Configured Threshold:  $MIN_SECURE_LEVEL"
echo "---------------------------"

if [ "$current_value" -ge "$MIN_SECURE_LEVEL" ]; then
    echo "STATUS: SECURE"
    exit 0
else
    echo "STATUS: NOT SECURE"
    exit 1
fi







