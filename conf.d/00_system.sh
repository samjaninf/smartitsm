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


## Base System


MODULE="system"
TITLE="Base System"
DESCRIPTION="system preparation"
PRIORITY="00"


## Installs this module.
function do_install {
    loginfo "Executing pre-checks..."

    logdebug "Checking user rights..."
    local user=`whoami`
    if [ "$user" != "root" ]; then
        logwarning "You need super user (root) rights."
        return 1
    fi

    logdebug "Checking distribution..."
    local release=`lsb_release --all 2> /dev/null | grep "Release" | awk '{print $NF}'`
    if [ "$?" -gt 0 ]; then
        logwarning "lsb_release is not available or returned with an error."
        return 1
    fi
    if [ "$release" != "14.04" ]; then
        logwarning "Distribution Ubuntu 14.04 LTS is required."
        return 1
    fi

    logdebug "Pre-checks are done."

    loginfo "Appending hostname to /etc/hosts..."
    echo -e "\n127.0.0.1\t$HOST\n" >> /etc/hosts || return 1

    loginfo "Renaming hostname in /etc/hostname..."
    echo -e "$HOST\n" > /etc/hostname || return 1

    loginfo "Upgrading system..."
    upgradeSystem || return 1

    loginfo "Installing administration packages..."
    installPackage "joe htop make cmake flex bison debconf-utils python-software-properties software-properties-common rcconf pwgen unzip subversion git pandoc imagemagick devscripts quilt libmodule-signature-perl libcpan-uploader-perl libgd-gd2-perl graphviz libexpat1-dev perl-doc nmap librrds-perl rrdtool libsnmp-dev mcrypt" || return 1

    # TODO Doesn't work:
    loginfo "Installing MariaDB..."
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    add-apt-repository -y 'deb http://mirrors.n-ix.net/mariadb/repo/10.0/ubuntu saucy main'
    apt-get update -y
    {
        echo "$MARIADB_DBA_PASSWORD"
        echo "$MARIADB_DBA_PASSWORD"
    } |
    debconf-set-selections <<< "mariadb-server mariadb-server/root_password password $MARIADB_DBA_PASSWORD" || return 1
    debconf-set-selections <<< "mariadb-server mariadb-server/root_password_again password $MARIADB_DBA_PASSWORD" || return 1
    installPackage mariadb-server mariadb-client || return 1

    loginfo "Tweaking MariaDB server configuration..."
    echo "[mysqld]
key_buffer_size=64M
table_open_cache=1024
sort_buffer_size=4M
read_buffer_size=1M
" > /etc/mysql/conf.d/smartitsm.cnf || return 1
    service mysql restart || return 1

    loginfo "Removing unnecessary MariaDB users..."
    executeMySQLQuery "DELETE FROM mysql.user WHERE Password = '';" || return 1
    # TODO Seems to be unnecessary:
    #executeMySQLQuery "DROP USER ''@'%';" || return 1

    loginfo "Installing web server..."
    installPackage "apache2 libapache2-mod-perl2 php5 php5-cli php5-json php5-curl php5-gd php5-imagick php5-ldap php5-mcrypt php5-mysql php5-pgsql php5-xdebug php-pear php5-xmlrpc php5-xsl" || return 1

    loginfo "Tweaking PHP configuration for Apache httpd..."
    echo "max_execution_time = 300
max_input_time = 60
memory_limit = 1024M
error_reporting = E_ALL & ~E_DEPRECATED
display_errors = Off
log_errors = On
html_errors = Off
post_max_size = 128M
upload_max_filesize = 128M
session.gc_maxlifetime = 86400
short_open_tag = On
" > /etc/php5/apache2/conf.d/smartitsm.ini || return 1

    loginfo "Activating PHP's mcrypt extension..."
    ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available/
    php5enmod mcrypt

    restartWebServer || return 1

    loginfo "Installing PostgreSQL..."
    installPackage "postgresql postgresql-client phppgadmin" || return 1
    # TODO change postgres's password
    # TODO edit /etc/postgresql/9.1/main/postgresql.conf
    # * listen_addresses = '*'
    # * port = 25321
    #service postgresql restart

    loginfo "Installing NTP deamon..."
    apt-get autoremove --purge -y ntpdate || return 1
    installPackage "ntp" || return 1

    loginfo "Installing phpMyAdmin (after both Apache HTTP and MariaDB deamons have been started)..."
    # TODO Use automatically apache2 as prefered webserver.
    # TODO Say "Yes" to run dbconfig-common.
    # TODO Use automatically MySQL DBA user's password.
    # TODO Leave field empty for phpMyAdmin user.
    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true" || return 1
    debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $MARIADB_DBA_PASSWORD" || return 1
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MARIADB_DBA_PASSWORD" || return 1
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $MARIADB_DBA_PASSWORD" || return 1
    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" || return 1
    installPackage "phpmyadmin" || return 1
    printf "

/** Generated by $PROJECT_SHORT_DESC $PROJECT_VERSION */
\$cfg['MaxTableList'] = 1024;
\$cfg['SuhosinDisableWarning'] = true;
\$cfg['LoginCookieValidity'] = 86400;
\$cfg['LoginCookieStore'] = 86400;
" >> /etc/phpmyadmin/config.inc.php || return 1

    loginfo "Installing OpenLDAP and phpLDAPAdmin..."
    # TODO Set automatically LDAP admin password:
    installPackage "slapd ldap-utils phpldapadmin" || return 1

    ## Apache httpd
    loginfo "Tweaking Apache httpd configuration..."
    a2enmod rewrite || return 1
    echo -e "\nServerName $HOST\n" >> /etc/apache2/conf-available/smartitsm.conf || return 1
    a2enconf smartitsm || return 1
    restartWebServer || return 1

    loginfo "Creating some important directories..."
    mkdir -p "$SMARTITSM_ROOT_DIR" || return 1
    mkdir -p "$TMP_DIR" || return 1

    return 0
}

## Installs homepage configuration.
function do_www_install {
    loginfo "Installing homepage configuration..."
    logdebug "Nothing to do. Skipping."
    return 0
}

## Upgrades this module.
function do_upgrade {
    upgradeSystem || return 1
    return 0
}

## Removes this module.
function do_remove {
    lognotice "Not implemented yet. Skipping."
    return 0
}
