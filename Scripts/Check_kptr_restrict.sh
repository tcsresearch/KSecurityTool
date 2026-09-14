#!/bin/bash

# Configuration and target definitions
CONFIG_FILE="security.conf"
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
