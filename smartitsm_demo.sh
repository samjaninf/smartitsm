## Packages
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get install -y joe htop make python-software-properties rcconf pwgen unzip subversion git pandoc apache2 libapache2-mod-perl2 php5 php5-cli php5-curl php5-gd php5-imagick php5-ldap php5-mcrypt php5-mysql php5-pgsql php5-suhosin php5-xcache php5-xdebug php-pear php5-xmlrpc php5-xsl mysql-server mysql-client libgd-gd2-perl graphviz libexpat1-dev perl-doc nmap librrds-perl rrdtool

## NTP
apt-get autoremove --purge -y ntpdate
apt-get install -y ntp

## phpMyAdmin (after MySQL server installation)
apt-get install -y phpmyadmin

## LDAP: OpenLDAP, phpLDAPAdmin
apt-get install -y slapd ldap-utils phpldapadmin

## SSH server
joe /etc/ssh/sshd_config
service ssh restart

## Hostname
## # cat /etc/hosts
## # ...
## # 127.0.0.1  demo.smartitsm.org
## # cat /etc/hostname
## # smartitsm

## Apache httpd
a2enmod rewrite
echo -e "ServerName demo.smartitsm.org\n" >> /etc/apache2/apache2.conf

## Icinga, Nagios Plugins, IDOUtils, Icinga Web, PNP4Nagios
## <https://wiki.icinga.org/display/howtos/Setting+up+Icinga+with+IDOUtils+on+Ubuntu>
## <https://wiki.icinga.org/display/howtos/Setting+up+Icinga+Web+on+Ubuntu>
## <https://wiki.icinga.org/display/howtos/Setting+up+PNP4Nagios+with+Icinga-Web>
add-apt-repository ppa:formorer/icinga
apt-get update
apt-get install icinga icinga-idoutils icinga-doc libdbd-mysql
cp /usr/share/doc/icinga-idoutils/examples/idoutils.cfg-sample /etc/icinga/modules/idoutils.cfg
# enable ido2db deamon:
joe /etc/default/icinga
service ido2db restart
service icinga restart
mysql -u root -p
# CREATE DATABASE icinga_web;
# GRANT USAGE ON *.* TO 'icinga_web'@'localhost' IDENTIFIED BY 'icinga_web' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;
# GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX ON icinga_web.* TO 'icinga_web'@'localhost';
# quit
wget http://downloads.sourceforge.net/project/icinga/icinga-web/1.7.2/icinga-web-1.7.2.tar.gz
tar xzf icinga-web-1.7.2.tar.gz
cd icinga-web-1.7.2/
mysql -u root -p icinga_web < etc/schema/mysql.sql
./configure --with-api-cmd-file=/var/lib/icinga/rw/icinga.cmd --with-conf-dir=/etc/icinga-web --with-log-dir=/var/log/icinga-web --with-cache-dir=/var/cache/icinga-web
make install
make install-apache-config
wget http://downloads.sourceforge.net/project/pnp4nagios/PNP-0.6/pnp4nagios-0.6.18.tar.gz
tar xzf pnp4nagios-0.6.18.tar.gz
cd pnp4nagios-0.6.18
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make all
make install install-webconf install-config install-init
mv /usr/local/pnp4nagios/etc/rra.cfg-sample /usr/local/pnp4nagios/etc/rra.cfg
# change log_type = file, log_level = 2, and load_threshold = 10.0
joe /usr/local/pnp4nagios/etc/npcd.cfg
# change $conf['nagios_base'] = "/cgi-bin/icinga";
joe /usr/local/pnp4nagios/etc/config.php
# edit icinga.cfg as described in howto
# edit commands.cfg as described in howto
service apache2 restart


## Perl, CPAN
perl -e 'for ( @INC ) { print -e $_ ? "Exists:  " : "Missing: ", $_, "\n" }'
mkdir -p /usr/local/lib/perl/5.14.2 /usr/local/share/perl/5.14.2 /usr/local/lib/site_perl
cpan
# o conf build_requires_install_policy yes
# o conf commit
# exit
cpan CPAN
cpan YAML
cpan GD::Text
cpan Moose
cpan XML::Entities
cpan XML::Simple
cpan Compress::Zlib
cpan DBI
cpan Apache::DBI
cpan Net::IP
cpan SOAP::Lite
cpan DBD::mysql
cpan Encode::HanExtra
cpan Mail::IMAPClient
cpan Net::DNS
cpan Net::SMTP::TLS::ButMaintained
cpan PDF::API2
cpan Text::CSV_XS
cpan LWP::UserAgent
cpan Digest::MD5
cpan Net::SSLeay
cpan Proc::Daemon
cpan Proc::PID::File
cpan Nmap::Parser
cpan Module::Install

## Request Tracker, RT-Extension-ReferenceIDoitObjects, RT-Extension-MandatoryFields
wget http://download.bestpractical.com/pub/rt/release/rt-4.0.7.tar.gz
tar xzf rt-4.0.7.tar.gz
cd rt-4.0.7/
./configure --enable-graphviz --enable-gd --enable-gpg --enable-ssl-mailgate
make testdeps
make fixdeps
make install
make initialize-database
cd ..
http://search.cpan.org/CPAN/authors/id/B/BH/BHEISIG/RT-Extension-ReferenceIDoitObjects-0.9.tar.gz
tar xzf RT-Extension-ReferenceIDoitObjects-0.9.tar.gz
cd RT-Extension-ReferenceIDoitObjects-0.9/
perl Makefile.PL
make
make test
make install
make initdb
cpan RT::Extension::MandatoryFields

## OCS Inventory NG server
## <http://wiki.ocsinventory-ng.org/index.php/Documentation:Server#Under_Linux_Operating_System.>
wget https://launchpad.net/ocsinventory-server/stable-2.0/2.0.5/+download/OCSNG_UNIX_SERVER-2.0.5.tar.gz
tar xzf OCSNG_UNIX_SERVER-2.0.5.tar.gz
cd OCSNG_UNIX_SERVER-2.0.5/
sh setup.sh
rm /usr/share/ocsinventory-reports/ocsreports/install.php
# check Apache httpd config 
joe /etc/apache2/conf.d/ocsinventory-server.conf
service apache2 restart

## Local OCS Inventory NG Agent
## <http://wiki.ocsinventory-ng.org/index.php/Documentation:UnixAgent>
wget https://launchpad.net/ocsinventory-unix-agent/stable-2.0/2.0.5/+download/Ocsinventory-Unix-Agent-2.0.5.tar.gz
tar xzf Ocsinventory-Unix-Agent-2.0.5.tar.gz
cd Ocsinventory-Unix-Agent-2.0.5/
perl Makefile.PL
make
make install

## OTRS, ReferenceIDoitObjects
wget http://ftp.otrs.org/pub/otrs/otrs-3.1.10.tar.bz2
tar xjf otrs-3.1.10.tar.bz2
mv otrs-3.1.9/ /opt/otrs/
perl /opt/otrs/bin/otrs.CheckModules.pl
useradd -d /opt/otrs/ -c 'OTRS user' otrs
usermod -aG www-data otrs
cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm
cp /opt/otrs/Kernel/Config/GenericAgent.pm.dist /opt/otrs/Kernel/Config/GenericAgent.pm
perl -cw /opt/otrs/bin/cgi-bin/index.pl
perl -cw /opt/otrs/bin/cgi-bin/customer.pl
perl -cw /opt/otrs/bin/otrs.PostMaster.pl
/opt/otrs/bin/otrs.SetPermissions.pl --otrs-user=otrs --web-user=www-data --otrs-group=www-data --web-group=www-data /opt/otrs
ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/conf.d/otrs.config
service apache2 restart
mysql -u root -p -e 'create database otrs charset utf8'
mysql -u root -p otrs < /opt/otrs/scripts/database/otrs-schema.mysql.sql
mysql -u root -p otrs < /opt/otrs/scripts/database/otrs-initial_insert.mysql.sql
mysql -u root -p otrs < /opt/otrs/scripts/database/otrs-schema-post.mysql.sql
mysql -u root -p -e 'GRANT ALL PRIVILEGES ON otrs.* TO otrs@localhost IDENTIFIED BY "otrs" WITH GRANT OPTION;'
mysql -u root -p -e 'FLUSH PRIVILEGES;'
# update config file:
joe /opt/otrs/Kernel/Config.pm
/opt/otrs/bin/otrs.CheckDB.pl
# get OTRS-Extension-ReferenceIDoitObjects-0.4.tar.gz
tar xzf OTRS-Extension-ReferenceIDoitObjects-0.4.tar.gz
/opt/otrs/bin/otrs.PackageManager.pl -a install -p ReferenceIDoitObjects-0.4/ReferenceIDoitObjects-0.4.opm
service apache2 restart
# TODO configure extension


## i-doit
svn co http://dev.synetics.de/svn/idoit/branches/idoit-pro /var/www/i-doit_svn
mkdir /var/www/i-doit_svn/icingaexport
chown www-data:www-data -R /var/www/i-doit_svn/
# TODO installation script
# configure Nagios module, add nagios user (with group Admin)
/var/www/i-doit_svn/controller -m nagios_export -u icinga -p icinga -i 1 -v -n demo.smartitsm.org
ln -s /var/www/i-doit_svn/icingaexport/objects/commands.cfg /etc/icinga/objects/i-doit_commands.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/contacts.cfg /etc/icinga/objects/i-doit_contacts.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/hostdependencies.cfg /etc/icinga/objects/i-doit_hostdependencies.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/hostescalations.cfg /etc/icinga/objects/i-doit_hostescalations.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/hostgroups.cfg /etc/icinga/objects/i-doit_hostgroups.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/hosts.cfg /etc/icinga/objects/i-doit_hosts.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/servicedependencies.cfg /etc/icinga/objects/i-doit_servicedependencies.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/serviceescalations.cfg /etc/icinga/objects/i-doit_serviceescalations.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/servicegroups.cfg /etc/icinga/objects/i-doit_servicegroups.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/services.cfg /etc/icinga/objects/i-doit_services.cfg
ln -s /var/www/i-doit_svn/icingaexport/objects/timeperiods.cfg /etc/icinga/objects/i-doit_timeperiods.cfg
#ln -s /var/www/i-doit_svn/icingaexport/nagios.cfg /etc/icinga/icinga.cfg
# TODO deploy bin/build_icinga_config_from_i-doit.sh as cron job
# TODO deploy "/var/www/i-doit_svn/controller -m nagios -u icinga -p icinga -i 1 -v" to write log files


## Homepage
INSTALL_DIR="/opt/smartitsm"
mkdir -p "$INSTALL_DIR"
cp -r www "$INSTALL_DIR"
cp etc/apache.conf /etc/apache/conf.d/smartitsm.conf
# fetch logos
local LOGO_DIR="${INSTALL_DIR}/logos"
mkdir -p "${LOGO_DIR}"
wget http://www.smartitsm.org/_media/i-doit/i-doit_logo.png -O "${LOGO_DIR}/i-doit_logo.png"
wget http://web.demo.icinga.org/icinga-web/images/icinga/icinga-logo-big.png -O "${LOGO_DIR}/icinga_logo.png"
wget http://bestpractical.com/images/bpslogo.png -O "${LOGO_DIR}/best_practical_logo.png"
wget http://www.otrs.com/fileadmin/templates/skins/skin_otrs/css/images/logo.gif -O "${LOGO_DIR}/otrs_logo.gif"
wget http://www.ocsinventory-ng.org/en/assets/components/modxss/images/logo.png -O "${LOGO_DIR}/ocs_inventory_ng_logo.png"

