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

