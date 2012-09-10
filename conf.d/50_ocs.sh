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


## Installs this module.
function do_install {
    cd "$TMP_DIR" || return 1
    
    loginfo "Installing OCS Inventory NG server..."
    wget https://launchpad.net/ocsinventory-server/stable-2.0/2.0.5/+download/OCSNG_UNIX_SERVER-2.0.5.tar.gz || return 1
    tar xzf OCSNG_UNIX_SERVER-2.0.5.tar.gz || return 1
    cd OCSNG_UNIX_SERVER-2.0.5/ || return 1
    {
        # Do you wish to continue ([y]/n)?
        echo "y"
        # Which host is running database server [localhost] ?
        echo "localhost"
        # On which port is running database server [3306] ?
        echo "3306"
        # Where is Apache daemon binary [/usr/sbin/apache2] ?
        echo "/usr/sbin/apache2"
        # Where is Apache main configuration file [/etc/apache2/apache2.conf] ?
        echo "/etc/apache2/apache2.conf"
        # Which user account is running Apache web server [www-data] ?
        echo "www-data"
        # Which user group is running Apache web server [www-data] ?
        echo "www-data"
        # Where is Apache Include configuration directory [/etc/apache2/conf.d/] ?
        echo "/etc/apache2/conf.d/"
        # Where is PERL Intrepreter binary [/usr/bin/perl] ?
        echo "/usr/bin/perl"
        # Do you wish to setup Communication server on this computer ([y]/n)?
        echo "y"
        # Where to put Communication server log directory [/var/log/ocsinventory-server] ?
        echo "/var/log/ocsinventory-server"
        # Do you allow Setup renaming Communication Server Apache configuration file to 'z-ocsinventory-server.conf' ([y]/n) ?
        echo "n"
        # Do you wish to setup Administration Server (Web Administration Console) on this computer ([y]/n)?
        echo "y"
        # Do you wish to continue ([y]/n)?
        echo "y"
        # Where to copy Administration Server static files for PHP Web Console [/usr/share/ocsinventory-reports] ?
        echo "/usr/share/ocsinventory-reports"
        # Where to create writable/cache directories for deployement packages, administration console logs, IPDiscover [/var/lib/ocsinventory-reports] ?
        echo "/var/lib/ocsinventory-reports"
    } | sh setup.sh || return 1
    logdebug "Setting up database..."
    executeMySQLQuery "CREATE DATABASE $OCS_DB_NAME;" || return 1
    executeMySQLQuery "CREATE USER '$OCS_DB_USERNAME'@'localhost' IDENTIFIED BY '$OCS_DB_PASSWORD';" || return 1
    executeMySQLQuery "GRANT ALL ON $OCS_DB_NAME.* TO '$OCS_DB_USERNAME'@'localhost';" || return 1
    executeMySQLQuery "FLUSH PRIVILEGES;" || return 1
    executeMySQLImport "$OCS_DB_NAME" "ocsreports/files/ocsbase_new.sql"
    logdebug "Removing install.php..."
    rm /usr/share/ocsinventory-reports/ocsreports/install.php || return 1
    # TODO There seems to be a bug while restarting Apache httpd:
    # "ocsinventory-server: Can't load SOAP::Transport::HTTP* - Web service will be unavailable"
    # see: <http://forums.ocsinventory-ng.org/viewtopic.php?id=9102>
    # Workaround:
    mv /etc/apache2/conf.d/ocsinventory-server.conf /etc/apache2/conf.d/ocsinventory-server.conf.bak || return 1
    cat /etc/apache2/conf.d/ocsinventory-server.conf.bak | grep -v "Apache::Ocsinventory::SOAP" > /etc/apache2/conf.d/ocsinventory-server.conf || return 1
    cd ..
    service apache2 restart || return 1

    loginfo "Installing local OCS Inventory NG Unix agent..."
    wget https://launchpad.net/ocsinventory-unix-agent/stable-2.0/2.0.5/+download/Ocsinventory-Unix-Agent-2.0.5.tar.gz || return 1
    tar xzf Ocsinventory-Unix-Agent-2.0.5.tar.gz || return 1
    cd Ocsinventory-Unix-Agent-2.0.5/ || return 1
    perl Makefile.PL || return 1
    make || return 1
    {
        # Do you want to configure the agent
        echo "y"
        # Where do you want to write the configuration file?
        echo "2" # /etc/ocsinventory-agent
        # Do you want to create the directory /etc/ocsinventory-agent?
        echo "y"
        # What is the address of your ocs server?
        echo "$HOST"
        # Do you need credential for the server? (You probably don't)
        echo "n"
        # Do you want to apply an administrative tag on this machine
        echo "y"
        # tag?
        echo "demo"
        # Do yo want to install the cron task in /etc/cron.d
        echo "y"
        # Where do you want the agent to store its files? (You probably don't need to change it)?
        echo "/var/lib/ocsinventory-agent"
        # Do you want to create the /var/lib/ocsinventory-agent directory?
        echo "y"
        # Should I remove the old linux_agent
        echo "y"
        # Do you want to use OCS-Inventory software deployment feature?
        echo "y"
        # Do you want to use OCS-Inventory SNMP scans feature?
        echo "y"
        # Do you want to send an inventory of this machine?
        echo "y"
    } | make install || return 1
    
    cd "$BASE_DIR" || return 1
    
    do_www_install || return 1
    
    return 0
}

## Installs homepage configuration.
function do_www_install {
    loginfo "Installing homepage configuration..."
    
    fetchLogo "http://www.ocsinventory-ng.org/en/assets/components/modxss/images/logo.png"
    
    loginfo "Installing module configuration..."
    echo "<?php

    \$demos['$MODULE'] = array(
        'title' => '$TITLE',
        'description' => '$DESCRIPTION',
        'url' => '$URL',
        'website' => '$IT_STACK',
        'versions' => '$VERSIONS',
        'credentials' => array(
            'Administrator' => array(
                'username' => '$OCS_ADMIN_USERNAME',
                'password' => '$OCS_ADMIN_PASSWORD'
            )
        ),
        'api' => array(
            'soap' => array(
                'type' => 'SOAP',
                'url' => \$protocol . '://' . \$host . '/ocsinterface/',
                'username' => '$OCS_ADMIN_USERNAME',
                'password' => '$OCS_ADMIN_PASSWORD'
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
