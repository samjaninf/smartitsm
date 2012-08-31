#!/bin/bash

function generatePassword {
    return $(pwgen -N 1 -s 12)
}

function installPackage {
    apt-get install -y $1
    local status=$?
    if [ "$status" -gt 0 ]; then
        
    else
    
    fi
    
    return "$status"
}
