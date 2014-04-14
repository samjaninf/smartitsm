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


## CPAN


MODULE="cpan"
TITLE="CPAN"
DESCRIPTION="Perl and CPAN"
VERSIONS="Perl 5.14.2, CPAN"
PRIORITY="20"


## Installs this module.
function do_install {
    loginfo "Preparing CPAN..."
    perl -e 'for ( @INC ) { print -e $_ ? "Exists:  " : "Missing: ", $_, "\n" }' || return 1
    mkdir -p /usr/local/lib/perl/5.14.2 /usr/local/share/perl/5.14.2 /usr/local/lib/site_perl || return 1
    {
        echo "o conf build_requires_install_policy yes"
        echo "o conf prerequisites_policy follow"
        echo "o conf commit"
        echo "exit"
    } | cpan || return 1

    # TODO "Somewhere" is a prompt for "Press <enter> to see the detailed list." and "Do you want to proceed with this configuration? [yes]" -- just enter:
    installCPANmodule "CPAN" || return 1
    installCPANmodule "YAML" || return 1
    installCPANmodule "YAML::XS" || return 1
    installCPANmodule "Test::Output" || return 1
    installCPANmodule "Test::Pod" || return 1
    installCPANmodule "Test::Pod::Coverage" || return 1
    installCPANmodule "Test::CPAN::Meta::JSON" || return 1
    installCPANmodule "Module::Install::AuthorTests" || return 1
    installCPANmodule "Module::Install::ExtraTests" || return 1
    installCPANmodule "Module::Versions::Report" || return 1
    installCPANmodule "GD::Text" || return 1
    installCPANmodule "Moose" || return 1
    installCPANmodule "XML::Entities" || return 1
    installCPANmodule "XML::Simple" || return 1
    installCPANmodule "XML::RSS" || return 1
    installCPANmodule "Compress::Zlib" || return 1
    installCPANmodule "DBI" || return 1
    installCPANmodule "Apache::DBI" || return 1
    installCPANmodule "Net::IP" || return 1
    installCPANmodule "SOAP::Lite" || return 1
    installCPANmodule "Encode::HanExtra" || return 1
    # TODO no extended tests needed, type 'n' and ENTER:
    installCPANmodule "Mail::IMAPClient" || return 1
    installCPANmodule "Net::DNS" || return 1
    installCPANmodule "Net::SMTP::TLS::ButMaintained" || return 1
    installCPANmodule "PDF::API2" || return 1
    installCPANmodule "Text::CSV_XS" || return 1
    installCPANmodule "Text::Password::Pronounceable" || return 1
    installCPANmodule "LWP::UserAgent" || return 1
    installCPANmodule "Digest::MD5" || return 1
    # TODO skip external tests (network connectivity required), type ENTER:
    installCPANmodule "Net::SSLeay" || return 1
    installCPANmodule "Proc::Daemon" || return 1
    installCPANmodule "Proc::PID::File" || return 1
    # TODO say "y" to all questions (5 times), type ENTER:
    installCPANmodule "Nmap::Parser" || return 1
    installCPANmodule "JSON::XS" || return 1
    installCPANmodule "Module::Install" || return 1
    # TODO no live tests, type 'N' and ENTER
    installCPANmodule "Crypt::SSLeay" || return 1
    installCPANmodule "GD::Graph" || return 1
    installCPANmodule "Net::LDAP" || return 1
    installCPANmodule "Crypt::Eksblowfish::Bcrypt" || return 1
    installCPANmodule "Time::ParseDate" || return 1
    installCPANmodule "IPC::Run3" || return 1
    installCPANmodule "Tree::Simple" || return 1
    installCPANmodule "HTML::Scrubber" || return 1
    installCPANmodule "HTML::Quoted" || return 1
    installCPANmodule "HTML::Mason" || return 1
    installCPANmodule "Symbol::Global::Name" || return 1
    installCPANmodule "DateTime::Format::Natural" || return 1
    installCPANmodule "Plack" || return 1
    installCPANmodule "Text::Wrapper" || return 1
    installCPANmodule "Regexp::Common::net::CIDR" || return 1
    installCPANmodule "Log::Dispatch" || return 1
    installCPANmodule "HTML::FormatText::WithLinks::AndTables" || return 1
    installCPANmodule "DateTime" || return 1
    installCPANmodule "CGI::Emulate::PSGI" || return 1
    installCPANmodule "Text::Quoted" || return 1
    installCPANmodule "Regexp::IPv6" || return 1
    installCPANmodule "CSS::Squish" || return 1
    installCPANmodule "DateTime::Locale" || return 1
    installCPANmodule "CGI::PSGI" || return 1
    installCPANmodule "Apache::Session" || return 1
    installCPANmodule "Date::Extract" || return 1
    installCPANmodule "HTML::Mason::PSGIHandler" || return 1
    installCPANmodule "MIME::Entity" || return 1
    installCPANmodule "Locale::Maketext::Lexicon" || return 1
    installCPANmodule "Module::Refresh" || return 1
    installCPANmodule "Role::Basic" || return 1
    installCPANmodule "Date::Manip" || return 1
    installCPANmodule "HTML::RewriteAttributes" || return 1
    installCPANmodule "Text::Template" || return 1
    installCPANmodule "Text::WikiFormat" || return 1
    installCPANmodule "DBIx::SearchBuilder" || return 1
    installCPANmodule "File::ShareDir" || return 1
    installCPANmodule "Regexp::Common" || return 1
    installCPANmodule "HTML::FormatText::WithLinks" || return 1
    installCPANmodule "Locale::Maketext::Fuzzy" || return 1
    installCPANmodule "Email::Address::List" || return 1
    installCPANmodule "Net::CIDR" || return 1
    installCPANmodule "UNIVERSAL::require" || return 1
    installCPANmodule "Email::Address" || return 1
    installCPANmodule "Plack::Handler::Starlet" || return 1
    installCPANmodule "MIME::Types" || return 1
    installCPANmodule "FCGI::ProcManager" || return 1
    installCPANmodule "FCGI" || return 1
    installCPANmodule "PerlIO::eol" || return 1
    installCPANmodule "GnuPG::Interface" || return 1
    installCPANmodule "GraphViz" || return 1
    installCPANmodule "Data::ICal" || return 1
    installCPANmodule "Mozilla::CA" || return 1
    installCPANmodule "String::ShellQuote" || return 1
    installCPANmodule "Crypt::X509" || return 1
    installCPANmodule "Convert::Color" || return 1

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
    lognotice "Not implemented yet. Skipping."
    return 0
}

## Removes this module.
function do_remove {
    lognotice "Not implemented yet. Skipping."
    return 0
}
