#!/bin/env bash

# Define Our Functions Library #
FUNCTIONS_FILE="RunSecurityChecks.bfunc"

# Sanity Check: Functions File #
if [ ! -f "$FUNCTIONS__FILE" ]; then
    echo "ERROR: Functions Library $FUNCTIONS_FILE not found...quitting!"
    exit 1
fi

# Main Program #

DisplayBanner

Check_bpf_jit_harden
NewLineCinema
Check_kptr_restrict
NewLineCinema
Check_ptrace_scope
NewLineCinema


