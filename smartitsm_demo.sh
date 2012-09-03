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

