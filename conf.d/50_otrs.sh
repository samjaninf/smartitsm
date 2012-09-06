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


MODULE="otrs"
TITLE="Open-source Ticket Request System (OTRS)"
DESCRIPTION="issue tracking system"
VERSIONS="OTRS Help Desk 3.1.10, ReferenceIDoitObjects 0.4 (closed beta)"
URL="/otrs/index.pl"
IT_STACK="http://www.smartitsm.org/it_stack/otrs"
PRIORITY="50"


## Installs this module.
function do_install {
    loginfo "Installing OTRS Help Desk..."
    cd "$TMP_DIR" || return 1
    download http://ftp.otrs.org/pub/otrs/otrs-3.1.10.tar.bz2 || return 1
    logdebug "Extracting tarball..."
    tar xjf otrs-3.1.10.tar.bz2 || return 1
    logdebug "Moving files to destination directory..."
    mv otrs-3.1.10/ /opt/otrs/ || return 1
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
    /opt/otrs/bin/otrs.SetPermissions.pl --otrs-user=otrs --web-user=www-data --otrs-group=www-data --web-group=www-data /opt/otrs || return 1
    logdebug "Installing Apache httpd configuration file..."
    ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/conf.d/otrs.config || return 1
    service apache2 restart || return 1
    executeMySQLQuery "create database $OTRS_DB_NAME charset utf8;" || return 1
    executeMySQLImport "$OTRS_DB_NAME" "/opt/otrs/scripts/database/otrs-schema.mysql.sql" || return 1
    executeMySQLImport "$OTRS_DB_NAME" "/opt/otrs/scripts/database/otrs-initial_insert.mysql.sql" || return 1
    executeMySQLImport "$OTRS_DB_NAME" "/opt/otrs/scripts/database/otrs-schema-post.mysql.sql" || return 1
    executeMySQLQuery "GRANT ALL PRIVILEGES ON $OTRS_DB_NAME.* TO $OTRS_DB_USERNAME@localhost IDENTIFIED BY '$OTRS_DB_PASSWORD' WITH GRANT OPTION;" || return 1
    executeMySQLQuery "FLUSH PRIVILEGES;" || return 1
    logdebug "Changing standard configuration settings for database..."
    cp /opt/otrs/Kernel/Config.pm /opt/otrs/Kernel/Config.pm.bak
    sed -e \
        "s/\$Self->{Database} = 'otrs';/\$Self->{Database} = '$OTRS_DB_NAME';/g" \
        "s/\$Self->{DatabaseUser} = 'otrs';/\$Self->{DatabaseUser} = '$OTRS_DB_USERNAME';/g" \
        "s/\$Self->{DatabasePw} = 'some-pass';/\$Self->{DatabasePw} = '$OTRS_DB_PASSWORD';/g" \
        /opt/otrs/Kernel/Config.pm.bak > /opt/otrs/Kernel/Config.pm
    /opt/otrs/bin/otrs.CheckDB.pl || return 1
    # TODO install cron jobs
    # TODO configure mail system
    # TODO configure scheduler (optional)
    
    loginfo "Installing OTRS-Extension-ReferenceIDoitObjects..."
    cd "$TMP_DIR" || return 1
    local tarball="OTRS-Extension-ReferenceIDoitObjects-0.4.tar.gz"
    if [ ! -r "$TMP_DIR/$tarball" ]; then
        lognotice "Please copy $tarball to $TMP_DIR and press [ENTER]. To skip the installation just ignore this."
        read userinteraction
    fi
    if [ -r "$TMP_DIR/$tarball" ]; then
        tar xzf "$tarball" || return 1
        /opt/otrs/bin/otrs.PackageManager.pl -a install -p ReferenceIDoitObjects-0.4/ReferenceIDoitObjects-0.4.opm || return 1
        service apache2 restart || return 1
        # TODO configure extension, add and configure dynamic fields
    fi
    
    cd "$BASE_DIR" || return 1
    
    do_www_install || return 1
    
    return 0
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
                'username' => 'root@localhost',
                'password' => 'root'
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
