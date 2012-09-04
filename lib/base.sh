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
## Base Library
##


## Includes shell script.
##   #1 Path to file
function includeShellScript {
    loginfo "Including shell script..."
    local file="$1"
    if [ ! -r "$file" ]; then
        logwarning "File '${file}' does not exist or is not readable."
        logerror "Cannot include shell script."
        return 1
    fi
    source "$1"
    logdebug "File '${file}' included."
    return 0
}

## Executes command.
##   $1 Command
function exe {
    logdebug "Executing command..."

    logdebug "Execute '${1}'"

    let "relevant = (($LOG_DEBUG & $VERBOSITY))"
    if [ "$relevant" -gt 0 ]; then
        eval $1
        local status="$?"
    else
        logdebug "Suppress output."
        eval $1 &> /dev/null
        local status="$?"
    fi

    return $status
}

## Logs events to standard output and log file.
##   $1 Log level
##   $2 Log message
function log {
    local level=""

    case "$1" in
        "$LOG_DEBUG") level="debug";;
        "$LOG_INFO") level="info";;
        "$LOG_NOTICE") level="notice";;
        "$LOG_WARNING") level="warning";;
        "$LOG_ERROR") level="error";;
        "$LOG_FATAL") level="fatal";;
        *) logwarning $"Unknown log event triggered.";;
    esac

    let "relevant = (($1 & $LOG_LEVEL))"
    if [ "$relevant" -gt 0 ]; then
        echo "[$level] $2" >> "$LOG_FILE"
    fi

    let "relevant = (($1 & $VERBOSITY))"
    if [ "$relevant" -gt 0 ]; then
        prntLn "[$level] $2"
    fi
}

function logdebug {
    log "$LOG_DEBUG" "$1"
}

function loginfo {
    log "$LOG_INFO" "$1"
}

function lognotice {
    log "$LOG_NOTICE" "$1"
}

function logwarning {
    log "$LOG_WARNING" "$1"
}

function logerror {
    log "$LOG_ERROR" "$1"
}

function logfatal {
    log "$LOG_FATAL" "$1"
}

## Calculates spent time.
function calculateSpentTime {
    loginfo "Calculating spent time..."
    local now=`date +%s`
    local sec=`expr $now - $START`
    local duration=""
    local div=0
    if [ "$sec" -ge 3600 ]; then
        div=`expr "$sec" \/ 3600`
        sec=`expr "$sec" - "$div" \* 3600`
        if [ "$div" = 1 ]; then
            duration="$div hour"
        elif [ "$div" -gt 1 ]; then
            duration="$div hours"
        fi
    fi
    if [ "$sec" -ge 60 ]; then
        if [ -n "$duration" ]; then
            duration="$duration and "
        fi
        div=`expr "$sec" \/ 60`
        sec=`expr "$sec" - "$div" \* 60`
        if [ "$div" = 1 ]; then
            duration="${duration}${div} minute"
        elif [ "$div" -gt 1 ]; then
            duration="${duration}${div} minutes"
        fi
    fi
    if [ "$sec" -ge 1 ]; then
        if [ -n "$duration" ]; then
            duration="$duration and "
        fi
        duration="${duration}${sec} second"
        if [ "$sec" -gt 1 ]; then
            duration="${duration}s"
        fi
    fi
    if [ -z "$duration" ]; then
        duration="0 seconds"
    fi
    logdebug "Spent time calculated."
    lognotice "Everything done after ${duration}. Exiting."
    return 0
}

## Clean finishing
function finishing {
    loginfo "Finishing operation..."
    calculateSpentTime
    logdebug "Exit code: 0"
    exit 0
}


## Clean abortion
##   $1 Exit code
function abort {
    loginfo "Aborting operation..."
    calculateSpentTime
    logdebug "Exit code: $1"
    logfatal "Operation failed."
    exit $1
}


## Print line to standard output
##   $1 string
function prntLn {
    echo -e "$1" 1>&2
    return 0
}


## Print line without trailing new line to standard output
##   $1 string
function prnt {
    echo -e -n "$1" 1>&2
    return 0
}


## Print some information about this script
function printVersion {
    loginfo "Printing some information about this script..."

    prntLn "$PROJECT_SHORT_DESC $PROJECT_VERSION"
    prntLn "Copyright (C) 2012 $PROJECT_COPYRIGHT"
    prntLn "This program comes with ABSOLUTELY NO WARRANTY."
    prntLn "This is free software, and you are welcome to redistribute it"
    prntLn "under certain conditions. Type '--license' for details."

    logdebug "Information printed."
    return 0
}


## Print license information
function printLicense {
    loginfo "Printing license information..."

    logdebug "Look for license text..."

    licenses[0]="${BASE_DIR}/COPYING"
    licenses[1]="/usr/share/common-licenses/AGPL-3"
    licenses[2]="/usr/share/doc/licenses/agpl-3.0.txt"

    for i in "${licenses[@]}"; do
        if [ -r "$i" ]; then
            logdebug "License text found under '${i}'."
            cat "$i" 1>&2
            logdebug "License information printed."
            return 0
        fi
    done

    logwarning "Cannot find any fitting license text on this system."
    logerror "Failed to print license. But it's the AGPL3+."
    return 1
}
