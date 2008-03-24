use strict;
use warnings;

use Data::Dumper;
use Test::More tests => 2;

{
    use WWW::OpenResty::Simple;

    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://resty.eeeeworks.org' }
    );

    my $res;
    eval {
        $res = $resty->get('/=/version');
    };
    ok !$@, 'no exception thrown';
    like Dumper($res), qr/OpenResty \d+\.\d+\.\d+ \(/, 'GET /=/version works';
}

