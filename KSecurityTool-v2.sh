#!/bin/env bash

# Taken From: https://linuxsecurity.com/news/security-projects/fedora-44-vs-kernel-exploits
#

########## Define Functions ##########

function KSecurity_Check() {
	echo "ptrace_scope: $(cat /proc/sys/kernel/yama/ptrace_scope)" 
	echo "pktr_restrict: $(cat /proc/sys/kernel/kptr_restrict)"
	echo "bpf_jit_harden: $(cat /proc/sys/net/core/bpf_jit_harden)"
	echo " "
}

function KSecurity_Enable() {
	echo "Enabling Added Security To The Linux Kernel..."
	echo "ptrace_scope: "
	echo 1 > /proc/sys/kernel/yama/ptrace_scope
	echo "kptr_restrict: "
	echo 1 > /proc/sys/kernel/kptr_restrict
	echo "bpf_jit_harden: "
	echo 2 > /proc/sys/net/core/bpf_jit_harden
	echo " "
}

########## Main Program ##########

KSecurity_Check
# KSecurity_Enable
#
