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


## OTRS

MODULE="otrs"
TITLE="Open-source Ticket Request System (OTRS)"
DESCRIPTION="issue tracking system"
LATEST="3.3.9"
LATEST_REFIDOITOBJ="0.8"
VERSIONS="OTRS Help Desk ${LATEST}, ReferenceIDoitObjects ${LATEST_REFIDOITOBJ}"
URL="/otrs/index.pl"
IT_STACK="http://www.smartitsm.org/it_stack/otrs"
PRIORITY="50"


## Installs this module.
function do_install {
    loginfo "Installing OTRS Help Desk..."
    cd "$TMP_DIR" || return 1
    download http://ftp.otrs.org/pub/otrs//otrs-"$LATEST".tar.gz || return 1
    logdebug "Extracting tarball..."
    tar xzf otrs-"$LATEST".tar.gz || return 1
    logdebug "Moving files to destination directory..."
    mv otrs-"$LATEST"/ /opt/otrs/ || return 1
    logdebug "Checking modules..."
    perl /opt/otrs/bin/otrs.CheckModules.pl || return 1
    logdebug "Adding system user..."
    useradd -d /opt/otrs/ -c 'OTRS user' otrs || return 1
    usermod -aG www-data otrs || return 1
    logdebug "Activating default configuration files..."
    cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm || return 1
    cp /opt/otrs/Kernel/Config/GenericAgent.pm.dist /opt/otrs/Kernel/Config/GenericAgent.pm || return 1
    logdebug "Checking whether all needed modules are installed..."
    perl -cw /opt/otrs/bin/cgi-bin/index.pl || return 1
    perl -cw /opt/otrs/bin/cgi-bin/customer.pl || return 1
    perl -cw /opt/otrs/bin/otrs.PostMaster.pl || return 1
    logdebug "Installing Apache httpd configuration file..."
    ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/otrs.conf || return 1
    a2enconf otrs || return 1
    restartWebServer || return 1
    logdebug "Setting file permissions..."
    /opt/otrs/bin/otrs.SetPermissions.pl --otrs-user=otrs --web-user=www-data --otrs-group=www-data --web-group=www-data /opt/otrs || return 1
    logdebug "Configuring database..."
    executeMySQLQuery "create database $OTRS_DB_NAME charset utf8;" || return 1
    executeMySQLImport "$OTRS_DB_NAME" "/opt/otrs/scripts/database/otrs-schema.mysql.sql" || return 1
    executeMySQLImport "$OTRS_DB_NAME" "/opt/otrs/scripts/database/otrs-initial_insert.mysql.sql" || return 1
    executeMySQLImport "$OTRS_DB_NAME" "/opt/otrs/scripts/database/otrs-schema-post.mysql.sql" || return 1
    executeMySQLQuery "GRANT ALL PRIVILEGES ON $OTRS_DB_NAME.* TO $OTRS_DB_USERNAME@localhost IDENTIFIED BY '$OTRS_DB_PASSWORD' WITH GRANT OPTION;" || return 1
    executeMySQLQuery "FLUSH PRIVILEGES;" || return 1
    logdebug "Changing standard configuration settings for database..."
    cp /opt/otrs/Kernel/Config.pm /opt/otrs/Kernel/Config.pm.bak
    sed \
        -e "s/\$Self->{Database} = 'otrs';/\$Self->{Database} = '$OTRS_DB_NAME';/g" \
        -e "s/\$Self->{DatabaseUser} = 'otrs';/\$Self->{DatabaseUser} = '$OTRS_DB_USERNAME';/g" \
        -e "s/\$Self->{DatabasePw} = 'some-pass';/\$Self->{DatabasePw} = '$OTRS_DB_PASSWORD';/g" \
        /opt/otrs/Kernel/Config.pm.bak > /opt/otrs/Kernel/Config.pm || return 1
    /opt/otrs/bin/otrs.CheckDB.pl || return 1
    logdebug "Activating cron jobs and scheduler..."
    cd var/cron
    for foo in *.dist; do cp $foo `basename $foo .dist`; done
    logdebug "Setting file permissions (again)..."
    /opt/otrs/bin/otrs.SetPermissions.pl --otrs-user=otrs --web-user=www-data --otrs-group=www-data --web-group=www-data /opt/otrs || return 1
    sudo -u otrs /opt/otrs/bin/Cron.sh start
    cp /opt/otrs/scripts/otrs-scheduler-linux /opt/otrs/scripts/otrs-scheduler-linux.bak
    sed \
        -e "s/User=otrs/User=otrs/g" \
        -e "s/Group=otrs/Group=www-data/g" \
        /opt/otrs/scripts/otrs-scheduler-linux.bak > /opt/otrs/scripts/otrs-scheduler-linux || return 1
    ln -s /opt/otrs/scripts/otrs-scheduler-linux /etc/init.d/
    service otrs-scheduler-linux restart
    # TODO configure mail system

    installReferenceIDoitObjects || return 1

    cd "$BASE_DIR" || return 1

    do_www_install || return 1

    return 0
}

function installReferenceIDoitObjects {
    loginfo "Installing OTRS-Extension-ReferenceIDoitObjects..."
    cd "$TMP_DIR" || return 1
    download http://opar.perl-services.de/package/download/682 || return 1
    mv 682 ReferenceIDoitObjects-"$LATEST_REFIDOITOBJ".opm
    /opt/otrs/bin/otrs.PackageManager.pl -a install -p ReferenceIDoitObjects-"$LATEST_REFIDOITOBJ".opm || return 1
    restartWebServer || return 1
    # TODO configure extension, add and configure dynamic fields
}

## Installs homepage configuration.
function do_www_install {
    loginfo "Installing homepage configuration..."

    fetchLogo "http://www.otrs.com/fileadmin/templates/skins/skin_otrs/css/images/logo.gif" "gif"

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
                'username' => '$OTRS_ADMIN_USERNAME',
                'password' => '$OTRS_ADMIN_PASSWORD'
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
