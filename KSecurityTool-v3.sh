#!/bin/env bash

# shellcheck disable=SC2034

# Taken From: https://linuxsecurity.com/news/security-projects/fedora-44-vs-kernel-exploits
#

KST_Version="26.11_r2"
KST_RootStatus="Unknown" # Default to "Unknown"; Use w/ CheckRoot2 to see if we should set to 1.
# NOTE: Display will show as Yes or No.

KST_ConfDir="$(pwd)/conf"
KST_FuncDir="$(pwd)/functions"

KST_ColorsFile="$(pwd)/$KST_ConfDir/Colors2.conf"
KST_FuncFile="$(pwd)/$KST_FuncDir/KSecurityTool.bfunc"

KST_BackupFile="KST_ConfigBackup.conf"
KST_Today="$(date +%Y%m%d)"

########## Define Functions - Main ##########
### TODO: Ensure all functions are inside $KST_FuncFile.
#          Source and remove code from script.

function KSecurity_DisplayBanner() {
	echo "KSecurityTool - Version $KST_Version."
	echo "-------------------------------------"
	echo "Backup File: 		$KST_BackupFile-$KST_Today"
	echo "Colors File: 		$KST_ColorsFile"
	echo "Functions File: 	$KST_FuncFile"
	echo "-------------------------------------"
	echo "Root Status: 		$RootStatusText"
	echo " "
}

function CheckRoot() { # To be removed after CheckRoot2 proves successful.
# TODO: Force root via sudo or stop.
if [ "$(whoami)" = 'root' ]; then
	echo "You are root"
else
	echo "You are not root"
fi
}

function CheckRoot2() {
# TODO: Force root via sudo or stop.
if [ "$(whoami)" = 'root' ]; then
	KST_RootStatus="1"
else
	KST_RootStatus="0"
fi
}

function KSecurity_Check() {
	# echo "ptrace_scope: $(cat /proc/sys/kernel/yama/ptrace_scope)" 
	echo "ptrace_scope: $(sudo cat /proc/sys/kernel/yama/ptrace_scope)" 
	echo "pktr_restrict: $(cat /proc/sys/kernel/kptr_restrict)"
	echo "bpf_jit_harden: $(cat /proc/sys/net/core/bpf_jit_harden)"
	echo " "
}

function KSecurity_Check2() {
	# First, check running config and store data as variables for friendly output display via KSecurity_DisplayRunningConfig().
	KSTValue_ptrace_scope="ptrace_scope: $(sudo cat /proc/sys/kernel/yama/ptrace_scope)"

	KSTValue_kptr_restrict="ptrace_scope: $(sudo cat /proc/sys/kernel/kptr_restrict)"

	KSTValue_bpf_jit_harden="bpf_jit_harden: $(cat /proc/sys/net/core/bpf_jit_harden)"

	# Now we display the data.
	KSecurity_DisplayRunningConfig

}


function KSecurity_DisplayRunningConfig() {
	Display_KSTValue_ptrace_scope
	Display_KSTValue_kptr_restrict
	Display_KSTValue_bpf_jit_harden
}
	
function KSecurity_BackupConfig() {
	# TODO: Test Configuration Save Feature.
	echo "Backing up configuration..."
	# echo "ptrace_scope: $(cat /proc/sys/kernel/yama/ptrace_scope)" > "$KST_BackupFile-$KST_Today"
	echo "ptrace_scope: $(sudo cat /proc/sys/kernel/yama/ptrace_scope)" > "$KST_BackupFile-$KST_Today"
	echo "pktr_restrict: $(cat /proc/sys/kernel/kptr_restrict)"	   >> "$KST_BackupFile-$KST_Today"
	echo "bpf_jit_harden: $(cat /proc/sys/net/core/bpf_jit_harden)" >> "$KST_BackupFile-$KST_Today"
	echo " "
}

########## Define Functions - Enable/Disable Security ##########
### TODO: Translate 1, 2, and 0 to [ENABLED], [DISABLED], etc.

function KSecurity_Enable() {
	echo "Enabling Added Security To The Linux Kernel..."
	echo "ptrace_scope: "
	# echo 1 > /proc/sys/kernel/yama/ptrace_scope
	# sudo echo 1 > /proc/sys/kernel/yama/ptrace_scope
	echo 1 | sudo tee /proc/sys/kernel/yama/ptrace_scope > /dev/null # Fixes SC2024.
	echo "kptr_restrict: "
	echo 1 > /proc/sys/kernel/kptr_restrict
	echo "bpf_jit_harden: "
	echo 2 > /proc/sys/net/core/bpf_jit_harden
	echo " "
}

function KSecurity_Disable() {
	echo "Disabling Added Security To The Linux Kernel..."
	echo "ptrace_scope: "
	# echo 0 > /proc/sys/kernel/yama/ptrace_scope
	echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope > /dev/null # Fixes SC2024.
	echo "kptr_restrict: "
	echo 0 > /proc/sys/kernel/kptr_restrict
	echo "bpf_jit_harden: "
	echo 0 > /proc/sys/net/core/bpf_jit_harden
	echo " "
}



########## Display Values in a friendly way ##########
function Display_KST_RootStatus() {
	if [[ "$KST_RootStatus" == "0" ]]; then
    	RootStatusText="No"
	elif [[ "$KST_RootStatus" == "1" ]]; then
    	RootStatusText="Yes"
	else
    	RootStatusText="Unknown"
	fi
# echo "Root Status: $RootStatusText"
}


function Display_KSTValue_ptrace_scope() {
	if [[ "$KSTValue_ptrace_scope" == "0" ]]; then
    	VDisplay_ptrace_scope_StatusText="DISABLED"
	elif [[ "$KSTValue_ptrace_scope" == "1" ]]; then
    	VDisplay_ptrace_scope_StatusText="ENABLED"
	else
    	VDisplay_ptrace_scope_StatusText="Unknown"
	fi
# echo "Root Status: $RootStatusText"
}

function Display_KSTValue_kptr_restrict() { # Extra value.
	if [[ "$KSTValue_kptr_restrict" == "0" ]]; then
    	VDisplay_kptr_restrict_StatusText="DISABLED"
	elif [[ "$KSTValue_kptr_restrict" == "1" ]]; then
    	VDisplay_kptr_restrict_StatusText="Level 1"
	elif [[ "$KSTValue_kptr_restrict" == "2" ]]; then
    	VDisplay_kptr_restrict_StatusText="Level 2"
	else
    	VDisplay_kptr_restrict_StatusText="Unknown"
	fi
# echo "Root Status: $RootStatusText"
}

function Display_KSTValue_bpf_jit_harden() {
	if [[ "$KSTValue_bpf_jit_harden" == "0" ]]; then
    	VDisplay_bpf_jit_harden_StatusText="DISABLED"
	elif [[ "$KSTValue_bpf_jit_harden" == "1" ]]; then
    	VDisplay_bpf_jit_harden_StatusText="ENABLED"
	else
    	VDisplay_bpf_jit_harden_StatusText="Unknown"
	fi
# echo "Root Status: $RootStatusText"
}


########## CASE Statement ##########
# Taken from sysctl-util.sh

# Usage function explaining how to run the script and what options are available
usage() {
    echo "Usage: $(basename "$0") [option]"
    echo " "
    echo "Options:"
    echo "  -s, --status        Check current status of Linux kernel security."
    echo "  -b, --backup        Backup kernel configuration."
    echo "  -e, --enable        Enable Linux kernel security."
	echo "  -d, --disable		Disable Linux kernel security."
    echo "  -h, --help          Display this help message."
    echo " "
    return 1
}

# Check if no arguments were provided
function CheckArgs() {
	if [ $# -eq 0 ]; then
    	usage
	fi
}

# Parse command-line arguments using a case statement
function RunCase() {
	case "$1" in
    	-s|--status)
        	KSecurity_Check2
        	;;
    	-b|--backup)
        	KSecurity_BackupConfig
        	;;
    	-e|--enable)
        	KSecurity_Enable
        	;;
		-d|--disable)
        	KSecurity_Disable
        	;;
    	-h|--help)
        	usage
        	;;
    	*)
        	echo "Error: Invalid option '$1'"
        	echo " "
        	usage
        	;;
	esac
}

########## Main Program ##########

CheckRoot2 # Run this first for KSecurity_DisplayBanner.
KSecurity_DisplayBanner

CheckArgs "$@"
RunCase "$@"

# KSecurity_Check
# KSecurity_BackupConfig
# KSecurity_Enable
# KSecurity_Disable
