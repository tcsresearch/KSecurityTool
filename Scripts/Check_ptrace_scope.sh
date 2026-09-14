#!/usr/bin/env bash

# Paths
PROC_FILE="/proc/sys/kernel/yama/ptrace_scope"
CONFIG_FILE="ptrace.conf"

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
