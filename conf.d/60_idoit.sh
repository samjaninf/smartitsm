#!/bin/bash


## smartITSM Demo System
## Copyright (C) 2014 synetics GmbH <http://www.smartitsm.org/>
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
LATEST="1.3"
VERSIONS="i-doit pro $LATEST"
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

## Installation directory
if [ -z "${ICINGA_EXPORT_DIR+1}" ]; then
    ICINGA_EXPORT_DIR="${INSTALL_DIR}/icingaexport"
fi

## Icinga configuration directory
if [ -z "${ICINGA_ETC_DIR+1}" ]; then
    ICINGA_ETC_DIR="/etc/icinga"
fi


## Installs this module.
function do_install {
    loginfo "Creating destination directory..."
    mkdir -p "$INSTALL_DIR" || return 1

    loginfo "Installing from local file..."

    local distribution="idoit-$LATEST.zip"

    if [ ! -r "${INSTALL_DIR}/${distribution}" ]; then
        logwarning "Main package $distribution is missing. Please copy it to $INSTALL_DIR and press [ENTER]."
        read userinteraction
    fi

    unzip "$distribution" || return 1

    mv "$distribution" "$TMP_DIR" || return 1

    #loginfo "Running setup script..."
    #cd "${INSTALL_DIR}/setup" || return 1
    #{
    #    echo "idoit_data"
    #    echo "idoit_system"
    #    echo "$HOST"
    #    echo "$MARIADB_DBA_PASSWORD"
    #    echo "Y"
    #} | ./install.sh || return 1

    chown www-data:www-data -R "$INSTALL_DIR" || return 1
    find . -type d -name \* -exec chmod 775 {} \;
    find . -type f -exec chmod 664 {} \;

    #loginfo "Patching configuration file..."
    #cp "${INSTALL_DIR}/src/config.inc.php" "${INSTALL_DIR}/src/config.inc.php.bak" || return 1
    # fix web root; increase session timer; enable admin center:
    # TODO configure SMTP:
    #   -e "s/\"smtp-host\"  => \"\",/\"smtp-host\"  => \"\",/g" \
    #sed \
    #    -e "s/\"www_dir\"       => \"\/\",/\"www_dir\"       => \"$URL\",/g" \
    #    -e "s/\"sess_time\"     => 600,/\"sess_time\"     => 86400,/g" \
    #    -e "s/\"admin\" => \"\",/\"admin\" => \"admin\",/g" \
    #    "${INSTALL_DIR}/src/config.inc.php.bak" > \
    #    "${INSTALL_DIR}/src/config.inc.php" || return 1

    loginfo "Installing Apache httpd configuration..."
    cp "${ETC_DIR}/${MODULE}.conf" /etc/apache2/conf-available/ || return 1
    a2enconf "$MODULE"
    restartWebServer || return 1

    loginfo "Running setup..."
    logwarning "Open Web GUI with a browser and run the setup. Then press [ENTER]."
    read userinteraction

    cd "$BASE_DIR" || return 1

    #if [ -d "$ICINGA_ETC_DIR" ]; then
    #    configureIcinga || return 1
    #fi

    #if [ -d "/opt/otrs" ]; then
    #    configureOTRS || return 1
    #fi

    #if [ -d "/opt/rt4" ]; then
    #    configureRT || return 1
    #fi

    #if [ -d "/usr/share/ocsinventory-reports" ]; then
    #    configureOCS || return 1
    #fi

    # TODO configure LDAP module

    do_www_install || return 1

    return 0
}

function importDemoDump {
    loginfo "Importing demo dump..."

    local mandator_db="idoit_data"
    logdebug "Mandator database: $mandator_db"

    local mandator_db="idoit_system"
    logdebug "System database: $system_db"

    local mandator_dump="${ETC_DIR}/idoit_data.sql"
    logdebug "Mandator dump file: $mandator_dump"

    local system_dump="${ETC_DIR}/idoit_system.sql"
    logdebug "System dump file: $system_dump"

    if [ ! -r "$mandator_dump" ]; then
        lognotice "Mandator dump file $mandator_dump is not accessible. Skip import."
        return 0
    fi

    if [ ! -r "$system_dump" ]; then
        lognotice "System dump file $system_dump is not accessible. Skip import."
        return 0
    fi

    executeMySQLImport "$mandator_db" "$mandator_dump" || return 1
    executeMySQLImport "$system_db" "$system_dump" || return 1
}

function configureIcinga {
    loginfo "Configuring i-doit's Nagios module..."

    # TODO Table columns changed in version 1.0!
    sed \
        -e "s/%HOST%/$HOST/g" \
        -e "s/%IDOUTILS_DB_USERNAME%/$IDOUTILS_DB_USERNAME/g" \
        -e "s/%IDOUTILS_DB_PASSWORD%/$IDOUTILS_DB_PASSWORD/g" \
        -e "s|%ICINGA_EXPORT_DIR%|$ICINGA_EXPORT_DIR|g" \
        "${ETC_DIR}/idoit_icinga.sql" > "${TMP_DIR}/idoit_icinga.sql" || return 1
    executeMySQLImport "idoit_data" "${TMP_DIR}/idoit_icinga.sql" || return 1

    logdebug "Adding user 'icinga'..."
    sed \
        -e "s/%USERNAME%/icinga/g" \
        -e "s/%PASSWORD%/icinga/g" \
        "${ETC_DIR}/idoit_user.sql" > "${TMP_DIR}/idoit_user.sql" || return 1
    executeMySQLImport "idoit_data" "${TMP_DIR}/idoit_user.sql" || return 1

    logdebug "Creating symbolic links of Icinga export files..."
    mkdir -p "$ICINGA_EXPORT_DIR" || return 1
    chown www-data:www-data -R "$ICINGA_EXPORT_DIR" || return 1
    "$INSTALL_DIR"/controller -m nagios_export -u icinga -p icinga -i 1 -v -n demo.smartitsm.org || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/commands.cfg "$ICINGA_ETC_DIR"/objects/i-doit_commands.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/contacts.cfg "$ICINGA_ETC_DIR"/objects/i-doit_contacts.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/hostdependencies.cfg "$ICINGA_ETC_DIR"/objects/i-doit_hostdependencies.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/hostescalations.cfg "$ICINGA_ETC_DIR"/objects/i-doit_hostescalations.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/hostgroups.cfg "$ICINGA_ETC_DIR"/objects/i-doit_hostgroups.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/hosts.cfg "$ICINGA_ETC_DIR"/objects/i-doit_hosts.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/servicedependencies.cfg "$ICINGA_ETC_DIR"/objects/i-doit_servicedependencies.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/serviceescalations.cfg "$ICINGA_ETC_DIR"/objects/i-doit_serviceescalations.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/servicegroups.cfg "$ICINGA_ETC_DIR"/objects/i-doit_servicegroups.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/services.cfg "$ICINGA_ETC_DIR"/objects/i-doit_services.cfg || return 1
    ln -s "$INSTALL_DIR"/icingaexport/objects/timeperiods.cfg "$ICINGA_ETC_DIR"/objects/i-doit_timeperiods.cfg || return 1
    #ln -s "$INSTALL_DIR"/icingaexport/nagios.cfg "$ICINGA_ETC_DIR"/icinga.cfg
    # TODO deploy bin/icinga_build_config_from_i-doit as cron job
    # TODO deploy ""$INSTALL_DIR"/controller -m nagios -u icinga -p icinga -i 1 -v" to write log files
}

function configureOCS {
    loginfo "Configuring idoit's module for OCS Inventory NG..."

    sed \
        -e "s/%OCS_DB_NAME%/$OCS_DB_NAME/g" \
        -e "s/%OCS_DB_USERNAME%/$OCS_DB_USERNAME/g" \
        -e "s/%OCS_DB_PASSWORD%/$OCS_DB_PASSWORD/g" \
        "${ETC_DIR}/idoit_ocs.sql" > "${TMP_DIR}/idoit_ocs.sql" || return 1
    executeMySQLImport "idoit_data" "${TMP_DIR}/idoit_ocs.sql" || return 1

    loginfo "Performing initial OCS Inventory NG import..."
    cd "$INSTALL_DIR" || return 1
    ./controller -v -u admin -p admin -i 1 -m ocs
}

function configureRT {
    loginfo "Configuring idoit's module 'Trouble Ticketing Systems (TTS)' for RT..."

    logdebug "Importing configuration..."
    sed \
        -e "s/%HOST%/$HOST/g" \
        -e "s/%USERNAME%/$RT_ADMIN_USERNAME/g" \
        -e "s/%PASSWORD%/$RT_ADMIN_PASSWORD/g" \
        "${ETC_DIR}/idoit_rt.sql" > "${TMP_DIR}/idoit_rt.sql" || return 1
    executeMySQLImport "idoit_data" "${TMP_DIR}/idoit_rt.sql" || return 1

    logdebug "Adding user 'rt'..."
    sed \
        -e "s/%USERNAME%/rt/g" \
        -e "s/%PASSWORD%/rt/g" \
        "${ETC_DIR}/idoit_user.sql" > "${TMP_DIR}/idoit_user.sql" || return 1
    executeMySQLImport "idoit_data" "${TMP_DIR}/idoit_user.sql" || return 1
}

function configureOTRS {
    loginfo "Configuring idoit's module 'Trouble Ticketing Systems (TTS)' for OTRS..."

    logdebug "Importing configuration..."
    sed \
        -e "s/%HOST%/$HOST/g" \
        -e "s/%USERNAME%/$OTRS_ADMIN_USERNAME/g" \
        -e "s/%PASSWORD%/$OTRS_ADMIN_PASSWORD/g" \
        "${ETC_DIR}/idoit_otrs.sql" > "${TMP_DIR}/idoit_otrs.sql" || return 1
    executeMySQLImport "idoit_data" "${TMP_DIR}/idoit_otrs.sql" || return 1

    logdebug "Adding user 'otrs'..."
    sed \
        -e "s/%USERNAME%/otrs/g" \
        -e "s/%PASSWORD%/otrs/g" \
        "${ETC_DIR}/idoit_user.sql" > "${TMP_DIR}/idoit_user.sql" || return 1
    executeMySQLImport "idoit_data" "${TMP_DIR}/idoit_user.sql" || return 1
}

## Installs homepage configuration.
function do_www_install {
    loginfo "Installing homepage configuration..."

    fetchLogo "http://www.smartitsm.org/_media/i-doit/i-doit_logo.png"

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
