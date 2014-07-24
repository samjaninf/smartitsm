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


## Request Tracker (RT)


MODULE="rt"
TITLE="Request Tracker (RT)"
DESCRIPTION="issue tracking system"
LATEST="4.2.6"
VERSIONS="Request Tracker (RT) ${LATEST}, RT::Authen::ExternalAuth, RT::Condition::NotStartedInBusinessHours, RT::Extension::LDAPImport, RT::Extension::MandatoryFields, RT::Extension::ReferenceIDoitObjects"
URL="/rt/"
IT_STACK="http://www.smartitsm.org/it_stack/request_tracker"
PRIORITY="50"

##
## Default Configuration
##

## TODO timezone, email, credentials,...


## Installs this module.
function do_install {
    cd "$TMP_DIR" || return 1

    loginfo "Installing RT..."
    download "http://download.bestpractical.com/pub/rt/release/rt-${LATEST}.tar.gz" || return 1
    tar xzf rt-"${LATEST}".tar.gz || return 1
    cd rt-"${LATEST}"/ || return 1
    ./configure --enable-graphviz --enable-gd --enable-gpg --enable-smime --with-db-dba="$MARIADB_DBA_USERNAME" --with-db-rt-user="$RT_DB_USERNAME" --with-db-rt-pass="$RT_DB_PASSWORD" || return 1
    ## Dry run: Do not abort after this command:
    make testdeps
    make fixdeps || return 1
    # Repeat testdeps and fixdeps (if necessary):
    make testdeps
    if [ "$?" -gt 0 ]; then
        make fixdeps || return 1
    fi
    # Finally, run last test:
    make testdeps || return 1
    make install || return 1
    echo "$MARIADB_DBA_PASSWORD" | make initialize-database || return 1
    cd .. || return 1

    installCPANmodule "RT::Authen::ExternalAuth" || return 1
    # TODO testing failed:
    #installCPANmodule "RT::Condition::NotStartedInBusinessHours" || return 1
    # TODO testing failed...
    #cpan -f -i RT::Extension::LDAPImport || return 1
    installCPANmodule "RT::Extension::MandatoryFields" || return 1

    installCPANmodule "RT::Extension::ReferenceIDoitObjects" || return 1
    echo "$RT_DB_PASSWORD" | /opt/rt4/sbin/rt-setup-database --action insert --datafile /opt/rt4/local/plugins/RT-Extension-ReferenceIDoitObjects/etc/initialdata || return 1

    cd "$BASE_DIR" || return 1

    loginfo "Configuring RT..."
    echo "# Any configuration directives you include  here will override
# RT's default configuration file, RT_Config.pm
#
# To include a directive here, just copy the equivalent statement
# from RT_Config.pm and change the value. We've included a single
# sample value below.
#
# This file is actually a perl module, so you can include valid
# perl code, as well.
#
# The converse is also true, if this file isn't valid perl, you're
# going to run into trouble. To check your SiteConfig file, use
# this command:
#
#   perl -c /path/to/your/etc/RT_SiteConfig.pm
#
# You must restart your webserver after making changes to this file.

Set(\$rtname, '$HOST');
Set(\$WebPath, '/rt');
Set(\$Organization , 'smartITSM');
Set(\$Timezone, 'Europe, Berlin');
Set(\$OwnerEmail, 'mail@smartitsm.org');
Set(\$WebDomain, '$HOST');

#Plugin('RT::Extension::QuickDelete');
#Plugin('RT::Extension::CommandByMail');
#Plugin('RT::Extension::LDAPImport');
#Plugin('RT::Authen::ExternalAuth');
Plugin('RT::Extension::MandatoryFields');
Plugin('RT::Extension::ReferenceIDoitObjects');
#Plugin('RT::Condition::NotStartedInBusinessHours');

## Logging
Set(\$LogToSyslog, undef);
Set(\$LogToFile, 'info');

## Little performance tweak
Set(\$AutocompleteOwners, 1);

## RT::Extension::ReferenceIDoitObject
Set(\$IDoitURL, 'http://demo.smartitsm.org/i-doit/index.php');
Set(\$IDoitAPI, \$IDoitURL . '?api=jsonrpc');
Set(\$IDoitUser, 'rt');
Set(\$IDoitPassword, '822050d9ae3c47f54bee71b85fce1487'); # 'rt'
Set(\$IDoitDefaultMandator, 1); # 'smartITSM'
Set(\$IDoitDefaultView, 'object'); # 'object', 'tree' or 'item'
Set(\$IDoitShowCustomFields, 0); # 1 ('yes') or 0 ('no')

## RT::Extension::MandatoryFields
Set(%MandatoryFields, (
        'Cc' => 'false',
        'AdminCc' => 'false',
        'Subject' => 'false',
        'Content' => 'false',
        'Attach' => 'false',
        'Status' => 'false',
        'Queue' => 'false',
        'Owner' => 'false',
        'Priority' => 'false',
        'InitialPriority' => 'false',
        'FinalPriority' => 'false',
        'TimeEstimated' => 'false',
        'TimeWorked' => 'false',
        'TimeLeft' => 'false',
        'Starts' => 'false',
        'Due' => 'false',
        'new-DependsOn' => 'false',
        'DependsOn-new' => 'false',
        'new-MemberOf' => 'false',
        'MemberOf-new' => 'false',
        'new-RefersTo' => 'false',
        'RefersTo-new' => 'false'
));

1;
" > /opt/rt4/etc/RT_SiteConfig.pm || return 1

    loginfo "Configuring Apache httpd configuration..."
    cp "$ETC_DIR"/rt.conf /etc/apache2/conf-available/rt.conf || return 1
    a2enconf rt

    # TODO Set up cron jobs!
    # TODO Configure mail gateway!

    loginfo "Performing clean restart..."
    "$BIN_DIR/rt_clean_cache_apache_restart.sh" || return 1

    do_www_install || return 1

    return 0
}

## Installs homepage configuration.
function do_www_install {
    loginfo "Installing homepage configuration..."

    fetchLogo "http://bestpractical.com/images/bpslogo.png"

    loginfo "Installing module configuration..."
    echo "<?php

    \$demos['$MODULE'] = array(
        'title' => '$TITLE',
        'description' => '$DESCRIPTION',
        'url' => '$URL',
        'website' => '$IT_STACK',
        'versions' => '$VERSIONS',
        'credentials' => array(
            'System User' => array(
                'username' => '$RT_ADMIN_USERNAME',
                'password' => '$RT_ADMIN_PASSWORD'
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
