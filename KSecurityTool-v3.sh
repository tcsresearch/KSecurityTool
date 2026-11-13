#!/bin/env bash

# Taken From: https://linuxsecurity.com/news/security-projects/fedora-44-vs-kernel-exploits
#

KST_Version="26.11_r1"
KST_RootStatus="0" # Dfeault 0; Use w/ CheckRoot2 to see if we should set to 1.

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
	echo "Root Status: 		$KST_RootStatus"
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


########## CASE Statement ##########
# Taken from sysctl-util.sh

# Usage function explaining how to run the script and what options are available
usage() {
    echo "Usage: $(basename "$0") [option]"
    echo ""
    echo "Options:"
    echo "  -s, --status        Check current status of Linux kernel security."
    echo "  -b, --backup        Backup kernel configuration."
    echo "  -e, --enable        Enable Linux kernel security."
	echo "  -d, --disable		Disable Linux kernel security."
    echo "  -h, --help          Display this help message."
    echo ""
    echo "Example:"
    echo "  $(basename "$0") --reload"
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
        	KSecurity_Check
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
        	# echo " "
        	usage
        	;;
	esac
}

########## Main Program ##########

CheckRoot2 # Run this first for KSecurity_DisplayBanner.
KSecurity_DisplayBanner

CheckArgs
RunCase

# KSecurity_Check
# KSecurity_BackupConfig
# KSecurity_Enable
# KSecurity_Disable
