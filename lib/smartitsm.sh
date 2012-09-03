#!/bin/bash


## smartITSM Demo System
## Copyright (C) 2012 synetics GmbH <http://www.smartitsm.org/>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU Affero General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Affero General Public License for more details.
##
## You should have received a copy of the GNU Affero General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.


##
## Project Library
##


function run_install {
    for conf_file in "$CONFIG_DIR"/*.sh; do
        includeShellScript "$conf_file" || abort 1
        loginfo "Installing module '$TITLE' ($DESCRIPTION) by $AUTHOR..."
        do_install
        if [ "$?" -gt 0 ]; then
            logerror "Installation failed."
            return 1
        fi
        logdebug "Module '$TITLE' installed."
    done
    
    return 0
}

function generatePassword {
    local password=`pwgen -N 1 -s 12`
    local status=$?
    if [ "$status" -gt 0 ]; then
        logwarning "pwgen returned with error."
        logerror "Generating password failed."
        return ""
    fi
    return "$password"
}

function installPackage {
    loginfo "Installing package(s) $1..."
    apt-get install -y $1
    local status=$?
    if [ "$status" -gt 0 ]; then
        logwarning "apt-get returned with error."
        logerror "Installation of package(s) $1 failed."
    else
        logdebug "Installation was successful."
    fi
    
    return "$status"
}

function upgradeSystem {
    loginfo "Upgrading system..."
    
    logdebug "Updating..."
    apt-get update -y || return 1
    
    logdebug "Upgrading..."
    apt-get upgrade -y || return 1
    
    logdebug "Dist-upgrading..."
    apt-get dist-upgrade -y || return 1
    
    logdebug "System upgraded."
    
    return 0
}

function download {
    loginfo "Downloading file '$1'..."
    wget --no-clobber "$1" || return 1
    return 0
}

function installCPANmodule {
    loginfo "Installing Perl module from CPAN..."
    cpan -i "$1"
    local status="$?"
    if [ "$status" -gt 0 ]; then
        logerror "Installation of module '$1' from CPAN failed."
        return "$status"
    fi
    loginfo "Module '$1' installed successfully."
    return 0
}
