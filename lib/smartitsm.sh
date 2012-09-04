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

## Runs installation.
function run_install {
    for conf_file in "$CONFIG_DIR"/*.sh; do
        includeShellScript "$conf_file" || abort 1
        loginfo "Installing module '$TITLE' ($DESCRIPTION)..."
        do_install
        if [ "$?" -gt 0 ]; then
            logerror "Installation failed."
            return 1
        fi
        logdebug "Module '$TITLE' installed."
    done
    
    return 0
}

## Runs homepage installation.
function run_www_install {
    for conf_file in "$CONFIG_DIR"/*.sh; do
        includeShellScript "$conf_file" || abort 1
        loginfo "Installing module '$TITLE' ($DESCRIPTION)..."
        do_www_install
        if [ "$?" -gt 0 ]; then
            logerror "Installation failed."
            return 1
        fi
        logdebug "Module '$TITLE' installed."
    done
    
    return 0
}

## Generates password.
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

## Installs distribution package(s).
##   $1 one or more space-separated packages
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

## Upgrades all distribution packages.
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

## Downloads a file.
##   $1 URL
function download {
    loginfo "Downloading file '$1'..."
    wget --no-clobber "$1" || return 1
    return 0
}

## Installs one or more CPAN modules.
##   $1 Space-separated list of modules
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

## Executes a MySQL query.
##   $1 SQL query
function executeMySQLQuery {
    loginfo "Executing SQL query with MySQL client..."
    logdebug "SQL query: $1"
    mysql -u root -p -e "$1"
    local status="$?"
    if [ "$status" -gt 0 ]; then
        logwarning "MySQL client returned with error."
        logerror "Executing SQL query with MySQL client failed."
        return "$status"
    fi
    return 0
}

## Imports into a MySQL database from file.
##   $1 Existing database
##   $2 File with SQL queries
function executeMySQLImport {
    loginfo "Executing SQL import with MySQL client..."
    logdebug "Database: $1"
    logdebug "SQL file: $2"
    mysql -u root -p otrs "$1" < "$2"
    local status="$?"
    if [ "$status" -gt 0 ]; then
        logwarning "MySQL client returned with error."
        logerror "Executing SQL import with MySQL client failed."
        return "$status"
    fi
    return 0
}

## Fetches a module logo from web. Optionally converts images to the PNG format.
##   $1 URL to image
##   $2 (optional) File extension (if not 'png')
function fetchLogo {
    loginfo "Fetching module logo..."

    logdebug "URL: $1"
    
    local extension="$2"
    if [ -z "$extension" ]; then
        extension="png"
    fi
    logdebug "File extension: $extension"
    
    wget "$1" -O "${LOGO_DIR}/${MODULE}_logo.$extension"
    local status="$?"
    if [ "$status" -gt 0 ]; then
        logwarning "wget returned with an error."
        logerror "Fetching logo for module '$MODULE' failed."
        return "$status"
    fi
    
    if [ "$extension" != "png" ]; then
        logdebug "Converting logo from $extension to png..."
        convert "${LOGO_DIR}/${MODULE}_logo.$extension" "${LOGO_DIR}/${MODULE}_logo.png"
        local status="$?"
        rm "${LOGO_DIR}/${MODULE}_logo.$extension"
        if [ "$status" -gt 0 ]; then
            logwarning "convert returned with error."
            logerror "Fetching logo for module '$MODULE' failed."
            return "$status"
        fi
    fi
    
    return 0
}

## Prints global usage
function printUsage {
    loginfo "Printing global usage..."

    prntLn "Usage: '$BASE_NAME [output] [options]'"
    prntLn ""
    prntLn "Output:"
    prntLn "    -q\t\t\tBe quiet (for scripting)."
    prntLn "    -v\t\t\tBe verbose."
    prntLn "    -V\t\t\tBe verboser."
    prntLn "    -D\t\t\tBe verbosest (for debugging)."
    prntLn ""
    prntLn "Options:"
    prntLn "    --install\t\tRun installation."
    prntLn "    --www-install\t\tRun homepage installation only."
    prntLn ""
    prntLn "Information:"
    prntLn "    -h, --help\t\tShow this help and exit."
    prntLn "    --license\t\tShow license information and exit."
    prntLn "    --version\t\tShow information about this script and exit."

    logdebug "Usage printed."
    return 0
}
