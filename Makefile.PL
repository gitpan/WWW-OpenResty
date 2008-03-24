use strict;
use lib '.';
use inc::Module::Install;

name                ('WWW-OpenResty');
license             ('perl');
author              ('Agent Zhang <agentzh@yahoo.cn>');
perl_version        ('5.006001');
all_from            ('lib/WWW/OpenResty.pm');

requires            ('Params::Util' => '0.31');
requires            ('YAML::Syck' => '1.04');
requires            ('JSON::Syck');
requires            ('LWP::UserAgent');
requires            ('Data::Dumper');
requires            ('Carp');

build_requires      ('Test::More');

auto_install();
WriteAll();

