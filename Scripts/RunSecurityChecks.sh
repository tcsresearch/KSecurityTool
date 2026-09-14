#!/bin/env bash


## TODO: Do we need root?

###############################################################################################################################################
# CONFIGURATION #                                                                                                                            #
###############################################################################################################################################

# Define Config Dir #
CONF_DIR="conf"

# Define Functions Dir #
FUNC_DIR="functions"

# Define Our Colors Library #
COLORS_FILE="Colors.conf"

# Define Our Functions Library #
FUNCTIONS_FILE="RunSecurityChecks.bfunc"

###############################################################################################################################################
# Sanity Checks #                                                                                                                             #
###############################################################################################################################################

# Sanity Check: Colors File Exists?
if [ -f "$CONF_DIR"/"$COLORS_FILE" ]; then
  echo "Sourcing Colors File..."
  source "$CONF_DIR"/"$COLORS_FILE"
else
  echo "ERROR: Colors Library $CONF_DIR/$COLORS_FILE not found...quitting!"
  return 1
fi

# Sanity Check: Functions File #
if [ -f "$FUNC_DIR"/"$FUNCTIONS_FILE" ]; then
  echo "Sourcing Functions File..."
  source "$FUNC_DIR"/"$FUNCTIONS_FILE"
else
  echo "ERROR: Functions Library $FUNC_DIR/$FUNCTIONS_FILE not found...quitting!"
  return 1
fi

############################################################################################################################################

# Main Program #

NewLine
KSecurity_DisplayBanner

Check_bpf_jit_harden
NewLineCinema
Check_kptr_restrict
NewLineCinema
Check_ptrace_scope
NewLineCinema


