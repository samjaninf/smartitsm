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


## i-doit


MODULE="idoit"
TITLE="i-doit pro"
DESCRIPTION="CMDB and IT documentation"
VERSIONS="i-doit v0.9.9-9 pro"
URL="/i-doit/"
IT_STACK="http://www.smartitsm.org/it_stack/i-doit"
PRIORITY="60"


##
## Default Configuration
##

## Installation directory
if [ -z "${INSTALL_DIR+1}" ]; then
    INSTALL_DIR="/opt/$MODULE"
fi


## Installs this module.
function do_install {
    loginfo "Installing i-doit..."
    # FIXME fetch and extract distribution to installation dir.
    mkdir -p "$INSTALL_DIR"/icingaexport || return 1
    chown www-data:www-data -R "$INSTALL_DIR"/
    # TODO installation script
    # TODO configure i-doit's Nagios module, add nagios user (with group Admin)

    loginfo "Installing Apache httpd configuration..."
    cp "${ETC_DIR}/${MODULE}.conf" /etc/apache2/conf.d/ || return 1
    
    if [ -d "/etc/icinga" ]; then
        loginfo "Creating symbolic links of Icinga export files..."
        "$INSTALL_DIR"/controller -m nagios_export -u icinga -p icinga -i 1 -v -n demo.smartitsm.org
        ln -s "$INSTALL_DIR"/icingaexport/objects/commands.cfg /etc/icinga/objects/i-doit_commands.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/contacts.cfg /etc/icinga/objects/i-doit_contacts.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/hostdependencies.cfg /etc/icinga/objects/i-doit_hostdependencies.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/hostescalations.cfg /etc/icinga/objects/i-doit_hostescalations.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/hostgroups.cfg /etc/icinga/objects/i-doit_hostgroups.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/hosts.cfg /etc/icinga/objects/i-doit_hosts.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/servicedependencies.cfg /etc/icinga/objects/i-doit_servicedependencies.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/serviceescalations.cfg /etc/icinga/objects/i-doit_serviceescalations.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/servicegroups.cfg /etc/icinga/objects/i-doit_servicegroups.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/services.cfg /etc/icinga/objects/i-doit_services.cfg
        ln -s "$INSTALL_DIR"/icingaexport/objects/timeperiods.cfg /etc/icinga/objects/i-doit_timeperiods.cfg
        #ln -s "$INSTALL_DIR"/icingaexport/nagios.cfg /etc/icinga/icinga.cfg
        # TODO deploy bin/build_icinga_config_from_i-doit.sh as cron job
        # TODO deploy ""$INSTALL_DIR"/controller -m nagios -u icinga -p icinga -i 1 -v" to write log files
    fi
    
    do_www_install || return 1

    return 0
}

## Installs homepage configuration.
function do_www_install {
    loginfo "Installing homepage configuration..."
    
    fetchLogo "http://www.smartitsm.org/_media/i-doit/i-doit_logo.png"
    
    loginfo "Installing "
    echo "<?php

    \$demos[$MODULE] = array(
        'title' => '$TITLE',
        'description' => '$DESCRIPTION',
        'url' => '$URL',
        'website' => '$IT_STACK',
        'versions' => '$VERSIONS',
        'credentials' => array(
            'Administrator' => array(
                'username' => 'admin',
                'password' => 'admin'
            )
        )
    );

?>
" > "${WWW_MODULE_DIR}/${PRIORITY}_${MODULE}.php" || return 1
    
    return 0
}

## Upgrades this module.
function do_upgrade {
    lognotice "Not implemented yet. Skipping."
    return 0
}

## Removes this module.
function do_remove {
    lognotice "Not implemented yet. Skipping."
    return 0
}
