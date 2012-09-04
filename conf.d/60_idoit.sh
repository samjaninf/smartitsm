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
##
## Versions:
##   i-doit v0.9.9-9 pro


MODULE="idoit"
TITLE="i-doit"
DESCRIPTION="i-doit v0.9.9-9 pro"


##
## Default Configuration
##

## TODO


## Installs this module.
function do_install {
    loginfo "Installing i-doit..."
    # FIXME fetch and extract distribution to /var/www/i-doit
    mkdir /var/www/i-doit/icingaexport
    chown www-data:www-data -R /var/www/i-doit/
    # TODO installation script
    # TODO configure i-doit's Nagios module, add nagios user (with group Admin)
    /var/www/i-doit/controller -m nagios_export -u icinga -p icinga -i 1 -v -n demo.smartitsm.org
    ln -s /var/www/i-doit/icingaexport/objects/commands.cfg /etc/icinga/objects/i-doit_commands.cfg
    ln -s /var/www/i-doit/icingaexport/objects/contacts.cfg /etc/icinga/objects/i-doit_contacts.cfg
    ln -s /var/www/i-doit/icingaexport/objects/hostdependencies.cfg /etc/icinga/objects/i-doit_hostdependencies.cfg
    ln -s /var/www/i-doit/icingaexport/objects/hostescalations.cfg /etc/icinga/objects/i-doit_hostescalations.cfg
    ln -s /var/www/i-doit/icingaexport/objects/hostgroups.cfg /etc/icinga/objects/i-doit_hostgroups.cfg
    ln -s /var/www/i-doit/icingaexport/objects/hosts.cfg /etc/icinga/objects/i-doit_hosts.cfg
    ln -s /var/www/i-doit/icingaexport/objects/servicedependencies.cfg /etc/icinga/objects/i-doit_servicedependencies.cfg
    ln -s /var/www/i-doit/icingaexport/objects/serviceescalations.cfg /etc/icinga/objects/i-doit_serviceescalations.cfg
    ln -s /var/www/i-doit/icingaexport/objects/servicegroups.cfg /etc/icinga/objects/i-doit_servicegroups.cfg
    ln -s /var/www/i-doit/icingaexport/objects/services.cfg /etc/icinga/objects/i-doit_services.cfg
    ln -s /var/www/i-doit/icingaexport/objects/timeperiods.cfg /etc/icinga/objects/i-doit_timeperiods.cfg
    #ln -s /var/www/i-doit/icingaexport/nagios.cfg /etc/icinga/icinga.cfg
    # TODO deploy bin/build_icinga_config_from_i-doit.sh as cron job
    # TODO deploy "/var/www/i-doit/controller -m nagios -u icinga -p icinga -i 1 -v" to write log files
    
    loginfo "Installing logo..."
    fetchLogo "$MODULE" "http://www.smartitsm.org/_media/i-doit/i-doit_logo.png"
    
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
