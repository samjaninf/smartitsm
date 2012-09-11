#   smartITSM Demo System

This project can help you building a complete, and fully-integrated tool chain for the IT service mangement (ITSM). It's meant as a powerful demonstration system – please, do not use it in productive environments but take a deeper look at how we think about a good way to install and configure [these tools](#modules).

*   Information about the demo system: <http://www.smartitsm.org/demo>
*   Git repository: <https://github.com/bheisig/smartitsm.git>
*   Issue tracker: <https://github.com/bheisig/smartitsm/issues>

The demo system is part of our _smartITSM_ initiative. The initiative stands for great open source tools working together to enhance the IT service management of an organization. [Read more about it on our website!](http://www.smartitsm.org/smartitsm).

**CAUTION: This is pre-alpha software which may break your system! Test it only in a non-productive environment!**


##  Modules

Each tool is encapsulated in a module. Currently, the demo system supports the following tools:

*   **i-doit** v0.9.9-9 pro
*   **Icinga** 1.7.1, Icinga-Web 1.7.2, IDOUtils 1.7.1, Nagios Plugins 1.4.15, PNP4Nagios 0.6.18
*   **OCS Inventory NG** 2.0.5, OCS Inventory NG Unix Agent 2.0.5
*   **OTRS Help Desk** 3.1.10, ReferenceIDoitObjects 0.4 (closed beta)
*   **Request Tracker (RT)** 4.0.7, RT::Authen::ExternalAuth, RT::Condition::NotStartedInBusinessHours, RT::Extension::LDAPImport, RT::Extension::MandatoryFields, RT::Extension::ReferenceIDoitObjects


##  Requirements

*   Ubuntu 12.04 LTS
*   super user (`root`) rights


##  Download

First of all, you have to fetch a copy of this repository. You can do this with a git client...

    git clone https://github.com/bheisig/smartitsm.git

...or fetch and extract a distribution tarball...

    wget https://github.com/bheisig/smartitsm/tarball/master -O smartitsm_demo_system.tar.gz
    tar xzf smartitsm_demo_system.tar.gz


##  Usage

There is a script called `bin/smartitsm.sh` which will do everything for you. Before using [edit the local configuration](#configuration) under `etc/config.sh` to meet your preferences.

Furthermore there are several files you should be aware of:

*   `bin/` – executables
    *   `build_icinga_configuration_from_i-doit.sh` – export Icinga configuration from i-doit and enable it in Icinga itself
    *   `rt_clean_cache_apache_restart.sh` – clean restart of Request Tracker (RT)
    *   `smartitsm.sh` – main script
*   `conf.d/` – module configuration
    *   `00_system.sh` – base system
    *   `20_cpan.sh` – CPAN
    *   […]
*   `etc/` – misc files
    *   `apache.conf` – Apache httpd configuration file for the homepage of the smartITSM Demo System
    *   `config.sh` – local configuration file for `bin/smartitsm.sh`
*   `lib` – libraries used by `bin/smartitsm.sh`
    *   `config.sh` – default configuration file
    *   […]
*   `www` – files for the smartITSM homepage

For more help type the following command:

    bin/smartitsm.sh --help

This will print a list of all options and a list of available modules.


### Configuration

The local configuration file is located under `etc/config.sh`. There is a default configuration file under `lib/config.sh` which may not be edited. To change a setting just copy it from the default configuration to the local one. The pre-configuration is suitable for a first get-in-touch, but is not very secured.


### Install Modules

To install all available modules just use the following command:

    bin/smartitsm.sh --install
    
If you prefer to select one or more modules use this:

    bin/smartitsm.sh --install --module MODULE1,MODULE2,MODULE3

Notice: Ordering is done by the modules' priorities. Each module has its own script file located under `conf.d/` with a priority number as prefix, e. g. `50_icinga.sh`.

    
### Upgrade Modules

Upgrading modules is currently not implemented yet.


### Remove Modules

Removing modules is currently not implemented yet.


##  Homepage of the smartITSM Demo System

The demo system has its own homepage which is accessible with any modern web browser in the web root. For example, the default URL is <http://demo.smartitsm.org/>, but is only available if your nameserver is configured properly. Of course, the web server is available under the hosts's IP address, but this may break the interaction between the modules.

Each module gets its own item on the homepage of the smartITSM Demo System.


##  Contribution

Your contribution is appreciated! Please, [read more about it at our website](http://www.smartitsm.org/contribution).


##  ToDo

...a.k.a. Roadmap

*   upgrade routines
*   remove routines
*   support for other GNU/Linux distributions
*   save state for better resuming
*   auto-create credentials and save them
*   apply log level to almost every used command
*   remove unnecessary user rights from MySQL


##   Copyright and License

Copyright (C) 2012 [synetics GmbH](http://www.i-doit.com/)

This software comes with ABSOLUTELY NO WARRANTY. For details, see the enclosed file COPYING for license information (AGPL). If you did not receive this file, see <http://www.gnu.org/licenses/agpl.txt>.

smartITSM and i-doit are Copyright synetics GmbH.

Icinga is a registered Trademark in the US, the EU and Germany.

Nagios is Copyright Nagios Enterprises, LLC.

Open-source Ticket Request System (OTRS) is Copyright OTRS AG.

Request Tracker (RT) is Copyright Best Practical Solutions, LLC.

All other trademarks, servicemarks, registered trademarks, and registered servicemarks are the property of their respective owners.
