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


## OTRS
##
## Documentation:
##   <http://wiki.ocsinventory-ng.org/index.php/Documentation:Server#Under_Linux_Operating_System.>
##   <http://wiki.ocsinventory-ng.org/index.php/Documentation:UnixAgent>


MODULE="ocs"
TITLE="OCS Inventory NG"
DESCRIPTION="hardware inventory"
VERSIONS="OCS Inventory NG 2.0.5, OCS Inventory NG Unix Agent 2.0.5"
URL="/ocsreports/"
IT_STACK="http://www.smartitsm.org/it_stack/ocs_inventory_ng"
PRIORITY="50"


##
## Default Configuration
##

## TODO


## Installs this module.
function do_install {
    cd "$TMP_DIR" || return 1
    
    loginfo "Installing OCS Inventory NG server..."
    wget https://launchpad.net/ocsinventory-server/stable-2.0/2.0.5/+download/OCSNG_UNIX_SERVER-2.0.5.tar.gz || return 1
    tar xzf OCSNG_UNIX_SERVER-2.0.5.tar.gz || return 1
    cd OCSNG_UNIX_SERVER-2.0.5/ || return 1
    sh setup.sh || return 1
    rm /usr/share/ocsinventory-reports/ocsreports/install.php || return 1
    # FIXME check Apache httpd config 
    #joe /etc/apache2/conf.d/ocsinventory-server.conf
    #joe /etc/apache2/conf.d/ocsinventory-reports.conf
    cd ..
    service apache2 restart || return 1

    loginfo "Installing local OCS Inventory NG Unix agent..."
    wget https://launchpad.net/ocsinventory-unix-agent/stable-2.0/2.0.5/+download/Ocsinventory-Unix-Agent-2.0.5.tar.gz || return 1
    tar xzf Ocsinventory-Unix-Agent-2.0.5.tar.gz || return 1
    cd Ocsinventory-Unix-Agent-2.0.5/ || return 1
    perl Makefile.PL || return 1
    make || return 1
    make install || return 1
    
    cd "$BASE_DIR" || return 1
    
    do_www_install || return 1
    
    return 0
}

## Installs homepage configuration.
function do_www_install {
    loginfo "Installing homepage configuration..."
    
    fetchLogo "http://www.ocsinventory-ng.org/en/assets/components/modxss/images/logo.png"
    
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
        ),
        'api' => array(
            'soap' => array(
                'type' => 'SOAP',
                'url' => \$protocol . '://' . \$host . '/ocsinterface/',
                'username' => 'admin',
                'password' => 'admin'
            ),
            'agent' => array(
                'type' => 'Agent interface',
                'url' => \$protocol . '://' . \$host . '/ocsinventory/'
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
