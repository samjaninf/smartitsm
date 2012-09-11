-- IDOUtils (MySQL access)

INSERT INTO isys_nagios_ndo  SET
    isys_nagios_ndo__ndodb_active = '1',
    isys_nagios_ndo__ndodb_ip = 'localhost',
    isys_nagios_ndo__ndodb_port = '3306',
    isys_nagios_ndo__ndodb_schema = 'icinga',
    isys_nagios_ndo__ndodb_prefix = 'icinga_',
    isys_nagios_ndo__ndodb_user = '%IDOUTILS_DB_USERNAME%',
    isys_nagios_ndo__ndodb_pass = '%IDOUTILS_DB_PASSWORD%';

-- Icinga Web GUI

INSERT INTO isys_nagios_nagioshosts SET
    isys_nagios_nagioshosts__host = '%HOST%',
    isys_nagios_nagioshosts__scriptalias = '/cgi-bin/icinga',
    isys_nagios_nagioshosts__export_path = '%ICINGA_EXPORT_DIR%';
