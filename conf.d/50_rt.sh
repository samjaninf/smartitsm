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


##
## Request Tracker (RT)
##
## Versions:
##   Request Tracker 4.0.7
##   RT::Authen::ExternalAuth
##   RT::Condition::NotStartedInBusinessHours
##   RT::Extension::LDAPImport
##   RT::Extension::MandatoryFields
##   RT::Extension::ReferenceIDoitObjects


MODULE="rt"
TITLE="Request Tracker (RT)"
DESCRIPTION="Request Tracker, RT::Authen::ExternalAuth, RT::Condition::NotStartedInBusinessHours, RT::Extension::LDAPImport, RT::Extension::MandatoryFields, RT::Extension::ReferenceIDoitObjects"
AUTHOR="Benjamin Heisig <bheisig@i-doit.org>"


##
## Default Configuration
##

## TODO timezone, email, credentials,...


## Installs this module.
function do_install {
    cd "$TMP_DIR" || return 1
    
    loginfo "Installing RT..."
    download "http://download.bestpractical.com/pub/rt/release/rt-4.0.7.tar.gz" || return 1
    tar xzf rt-4.0.7.tar.gz || return 1
    cd rt-4.0.7/ || return 1
    ./configure --enable-graphviz --enable-gd --enable-gpg --enable-ssl-mailgate || return 1
    make testdeps || return 1
    make fixdeps || return 1
    make install || return 1
    make initialize-database || return 1
    cd .. || return 1

    installCPANmodule "RT::Authen::ExternalAuth" || return 1
    installCPANmodule "RT::Condition::NotStartedInBusinessHours" || return 1
    installCPANmodule "RT::Extension::LDAPImport" || return 1
    installCPANmodule "RT::Extension::MandatoryFields" || return 1

    loginfo "Installing RT::Extension::MandatoryFields..."
    download "http://search.cpan.org/CPAN/authors/id/B/BH/BHEISIG/RT-Extension-ReferenceIDoitObjects-0.9.tar.gz" || return 1
    tar xzf RT-Extension-ReferenceIDoitObjects-0.9.tar.gz || return 1
    cd RT-Extension-ReferenceIDoitObjects-0.9/ || return 1
    perl Makefile.PL || return 1
    make || return 1
    make test || return 1
    make install || return 1
    make initdb || return 1
    
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
# this comamnd:
#
#   perl -c /path/to/your/etc/RT_SiteConfig.pm
#
# You must restart your webserver after making changes to this file.

Set(\$rtname, '$HOSTNAME');
Set(\$WebPath, '/rt');
Set(\$Organization , 'smartITSM');
Set(\$Timezone, 'Europe, Berlin');
Set(\$OwnerEmail, 'mail@smartitsm.org');
Set(\$WebDomain, '$HOSTNAME');

# You must install Plugins on your own, this is only an example
# of the correct syntax to use when activating them.
# There should only be one @Plugins declaration in your config file.
#Set(@Plugins,(qw(RT::Extension::QuickDelete RT::Extension::CommandByMail)));

# TODO RT::Extension::LDAPImport RT::Authen::ExternalAuth
Set(@Plugins, qw(
    RT::Extension::MandatoryFields
    RT::Extension::ReferenceIDoitObjects
    RT::Condition::NotStartedInBusinessHours
));

## Logging
Set(\$LogToSyslog, undef);
Set(\$LogToFile , 'info');

## RT::Extension::ReferenceIDoitObject
Set(\$IDoitURL, 'http://demo.smartitsm.org/i-doit_svn/index.php');
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
    echo "Alias /rt /opt/rt4/share/html

<Directory /opt/rt4/share/html>
        AddDefaultCharset UTF-8
</Directory>

<Location /rt>
        Order allow,deny
        Allow from all

        AddDefaultCharset UTF-8

        SetHandler modperl
        PerlResponseHandler Plack::Handler::Apache2
        PerlSetVar psgi_app /opt/rt4/sbin/rt-server
</Location>

<Perl>
        use Plack::Handler::Apache2;
        Plack::Handler::Apache2->preload('/opt/rt4/sbin/rt-server');
</Perl>
" > /etc/apache2/conf.d/rt.conf || return 1

    loginfo "Performing clean restart..."
    "$BIN_DIR/rt_clean_cache_apache_restart.sh" || return 1
    
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