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


## Icinga
##
## Documentation:
##   <https://wiki.icinga.org/display/howtos/Setting+up+Icinga+with+IDOUtils+on+Ubuntu>
##   <https://wiki.icinga.org/display/howtos/Setting+up+Icinga+Web+on+Ubuntu>
##   <https://wiki.icinga.org/display/howtos/Setting+up+PNP4Nagios+with+Icinga-Web>


MODULE="icinga"
TITLE="Icinga"
DESCRIPTION="network monitoring"
VERSIONS="Icinga 1.7.1, Icinga-Web 1.7.2, IDOUtils 1.7.1, Nagios Plugins 1.4.15, PNP4Nagios 0.6.18"
URL="/icinga/"
IT_STACK="http://www.smartitsm.org/it_stack/icinga"
PRIORITY="50"


##
## Default Configuration
##

## TODO


## Installs this module.
function do_install {
    loginfo "Installing packages..."
    add-apt-repository ppa:formorer/icinga || return 1
    apt-get update || return 1
    installPackage "icinga icinga-idoutils icinga-doc libdbd-mysql" || return 1
    
    loginfo "Activating IDOUtils..."
    cp /usr/share/doc/icinga-idoutils/examples/idoutils.cfg-sample /etc/icinga/modules/idoutils.cfg || return 1
    # enable ido2db deamon:
    echo -e "\nIDO2DB=yes\n" >> /etc/default/icinga || return 1
    service ido2db restart || return 1
    service icinga restart || return 1
    
    loginfo "Installing Icinga-Web..."
    mysql -u root -p -e "CREATE DATABASE icinga_web;" || return 1
    mysql -u root -p -e "GRANT USAGE ON *.* TO 'icinga_web'@'localhost' IDENTIFIED BY 'icinga_web' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;" || return 1
    mysql -u root -p -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX ON icinga_web.* TO 'icinga_web'@'localhost';" || return 1
    cd "$TMP_DIR" || return 1
    download "http://downloads.sourceforge.net/project/icinga/icinga-web/1.7.2/icinga-web-1.7.2.tar.gz" || return 1
    tar xzf icinga-web-1.7.2.tar.gz || return 1
    cd icinga-web-1.7.2/ || return 1
    mysql -u root -p icinga_web < etc/schema/mysql.sql || return 1
    ./configure --with-api-cmd-file=/var/lib/icinga/rw/icinga.cmd --with-conf-dir=/etc/icinga-web --with-log-dir=/var/log/icinga-web --with-cache-dir=/var/cache/icinga-web || return 1
    make install || return 1
    make install-apache-config || return 1
    cd "$BASE_DIR" || return 1
    
    loginfo "Installing PNP4Nagios..."
    cd "$TMP_DIR" || return 1
    download "http://downloads.sourceforge.net/project/pnp4nagios/PNP-0.6/pnp4nagios-0.6.18.tar.gz" || return 1
    tar xzf pnp4nagios-0.6.18.tar.gz || return 1
    cd pnp4nagios-0.6.18 || return 1
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios || return 1
    make all || return 1
    make install install-webconf install-config install-init || return 1
    cd "$BASE_DIR" || return 1
    mv /usr/local/pnp4nagios/etc/rra.cfg-sample /usr/local/pnp4nagios/etc/rra.cfg || return 1
    echo -e "\n\nlog_type = file\nlog_level = 2\nload_threshold = 10.0\n" >> /usr/local/pnp4nagios/etc/npcd.cfg || return 1
    echo -e "\n<?php\n\$conf['nagios_base'] = '/cgi-bin/icinga';\n?>\n" >> /usr/local/pnp4nagios/etc/config.php || return 1
    echo "
process_performance_data=1

host_perfdata_file=/usr/local/pnp4nagios/var/host-perfdata
service_perfdata_file=/usr/local/pnp4nagios/var/service-perfdata

service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\tTIMET::\$TIMET$\tHOSTNAME::\$HOSTNAME$\tSERVICEDESC::\$SERVICEDESC$\tSERVICEPERFDATA::\$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::\$SERVICECHECKCOMMAND$\tHOSTSTATE::\$HOSTSTATE$\tHOSTSTATETYPE::\$HOSTSTATETYPE$\tSERVICESTATE::\$SERVICESTATE$\tSERVICESTATETYPE::\$SERVICESTATETYPE$

host_perfdata_file_template=DATATYPE::HOSTPERFDATA\tTIMET::\$TIMET$\tHOSTNAME::\$HOSTNAME$\tHOSTPERFDATA::\$HOSTPERFDATA$\tHOSTCHECKCOMMAND::\$HOSTCHECKCOMMAND$\tHOSTSTATE::\$HOSTSTATE$\tHOSTSTATETYPE::\$HOSTSTATETYPE$

service_perfdata_file_mode=a
host_perfdata_file_mode=a

service_perfdata_file_processing_interval=30
host_perfdata_file_processing_interval=30

service_perfdata_file_processing_command=process-service-perfdata-file
host_perfdata_file_processing_command=process-host-perfdata-file
" >> /etc/icinga/icinga.cfg || return 1
echo "
# pnp
define command{
        command_name    process-service-perfdata-file
        command_line    /bin/mv /usr/local/pnp4nagios/var/service-perfdata /usr/local/pnp4nagios/var/spool/service-perfdata.\$TIMET$
}

define command{
        command_name    process-host-perfdata-file
        command_line    /bin/mv /usr/local/pnp4nagios/var/host-perfdata /usr/local/pnp4nagios/var/spool/host-perfdata.\$TIMET$
}
" >> /etc/icinga/commands.cfg || return 1

    loginfo "Restarting web server..."
    service apache2 restart || return 1
    
    do_www_install || return 1
    
    return 0
}

## Installs homepage.
function do_www_install {
    loginfo "Installing homepage configuration..."
    
    fetchLogo "http://web.demo.icinga.org/icinga-web/images/icinga/icinga-logo-big.png"
    
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
                'username' => 'icingaadmin',
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
