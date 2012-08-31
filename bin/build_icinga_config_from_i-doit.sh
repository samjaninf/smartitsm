#!/bin/bash

/var/www/i-doit_svn/controller -m nagios_export -u icinga -p icinga -i 1 -v -n demo.smartitsm.org
md5sum --status -c /tmp/i-doit_icinga.md5
status="$?"

if [ "$status" -gt 0 ]; then
    echo "Reloading Icinga configuration..."
    service icinga reload
    find /etc/icinga /var/www/i-doit_svn/icingaexport -type -f -print0 | xargs -0 md5sum > /tmp/i-doit_icinga.md5
else
    echo "Icinga configuration is up-to-date."
fi

exit 0
