use strict;
use lib '.';
use inc::Module::Install;

name                ('WWW-OpenResty');
license             ('perl');
author              ('Agent Zhang <agentzh@yahoo.cn>');
perl_version        ('5.006001');
all_from            ('lib/WWW/OpenResty.pm');

requires            ('Params::Util' => '0.31');
requires            ('JSON::XS' => '2.1');
requires            ('LWP::UserAgent');
requires            ('Carp');
requires            ('Digest::MD5');

build_requires      ('Test::More');
build_requires      ('Data::Dumper');

auto_install();
WriteAll();

