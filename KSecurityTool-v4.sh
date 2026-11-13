#!/bin/env bash

# shellcheck disable=SC2034,SC2154
# shellcheck source=/dev/null

####################################################################################################################################
# SanityChecker Functions #																										   #
####################################################################################################################################
# Function to confirm a file exists before sourcing it.

SanityChecker_WithColor() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        echo -e "${brightyellow}Sourcing: ${brightblue}$file${reset}"
        source "$file"
    else
        echo -e "${red}ERROR: File not found: $file${reset}"
    fi
}

SanityChecker_NoColor() {
	local file="$1"

 	if [[ -f "$file" ]]; then
    	echo "  Sourcing: $file "
        source "$file"
    else
        echo "	ERROR: File not found: $file "
    fi
}

function SanityChecker() {
# Alias function for pointing to either SanityChecker_WithColor or SanityChecker_NoColor, depending on whether or not $COLORS_FILE is loaded.
	[[ "$COLORS_FILE_LOADED" == "TRUE" ]] && SanityChecker_WithColor "$@"

	[[ "$COLORS_FILE_LOADED" == "FALSE" ]] && SanityChecker_NoColor "$@"
}
	
####################################################################################################################################
# Source If Exists Function # 																									   #
####################################################################################################################################
# Function to source files in a given directory with a specific extension

source_folder_if_exist() {
    local dir="$1"
    local pattern="$2"
    if [[ -d "$dir" ]]; then
        echo "${brightwhite} Sourcing files from: ${brightyellow} $dir ${reset}"
	echo "-------------------------------------------------------------------------------------------"
	# Use a glob to find matching files and loop through them
        for file in "$dir"/$pattern; do
            # Check if the glob found actual files (and not just the literal pattern if no files match)
            if [[ -f "$file" ]]; then
                echo "  ${brightyellow} Sourcing: ${brightblue} $file ${reset}"
                source "$file"
            fi
        done
    else
        echo "${red} Directory not found: $dir ${reset}"
    fi
}


####################################################################################################################################
####################################################################################################################################

# Taken From: https://linuxsecurity.com/news/security-projects/fedora-44-vs-kernel-exploits

KST_Version="26.11_r3"
KST_RootStatus="Unknown" # Default to "Unknown"; Use w/ CheckRoot2 to see if we should set to 1.
# NOTE: Display will show as Yes or No.

KST_ConfDir="$(pwd)/conf"
KST_FuncDir="$(pwd)/functions"

KST_ColorsFile="$KST_ConfDir/Colors2.conf"
KST_FuncFile="$KST_FuncDir/KSecurityTool.bfunc"

KST_BackupFile="KST_ConfigBackup.conf"
KST_Today="$(date +%Y%m%d)"

########## Define Display Functions ##########

function DisplayLine() {
	echo " ${brightblue}__________________________________________________${reset}"
}

function NewLine() {
	echo " "
}

########## Sanity Checker - Colors File ##########
# Source our Color Config

SanityChecker $KST_ColorsFile

### TODO: Remove the SourceColorsFile_Old function if 'SanityChecker $KST_ColorsFile' works as expected.
function SourceColorsFile_Old() {
  if [ -f "$KST_ColorsFile" ]; then
      source "$KST_ColorsFile"
	    COLORS_FILE_LOADED="TRUE"
	    DisplayLine
	    echo " ${green} Colors File ${brightwite} $KST_ColorsFile ${green} Loaded Successfully. ${reset}"
  else
      echo " ${red} ERROR: Color configuration file not found at ${brightwhite} $KST_ColorsFile. ${reset}" >&2
  fi
}

########## Sanity Checker - Functions File ##########
SanityChecker $KST_FuncFile


########## Main Program ##########

CheckRoot2 # Run this first for KSecurity_DisplayBanner.
KSecurity_DisplayBanner

CheckArgs "$@"
RunCase "$@"

# KSecurity_Check
# KSecurity_BackupConfig
# KSecurity_Enable
# KSecurity_Disable
