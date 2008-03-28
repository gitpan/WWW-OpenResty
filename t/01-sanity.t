use strict;
use warnings;

use Data::Dumper;
use WWW::OpenResty::Simple;
use Test::More tests => 6;

{

    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://resty.eeeeworks.org' }
    );

    my $res;
    eval {
        $res = $resty->get('/=/version');
    };
    ok !$@, 'no exception thrown';
    if ($@) { warn $@ }
    ok $res, 'res is defined';
    like Dumper($res), qr/OpenResty \d+\.\d+\.\d+ \(/, 'GET /=/version works';
}

{
    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://resty.eeeeworks.org' }
    );

    my $res;
    eval {
        $res = $resty->get('/=/model');
    };
    ok !$res, 'res is not defined as expected';
    ok $@, 'exception thrown as expected';
    like $@, qr/Login required.*?at .*?sanity\.t/s, 'GET /=/version works';
}

