use strict;
use warnings;

use utf8;
use Data::Dumper;
use WWW::OpenResty::Simple;
use Test::More tests => 19;

{

    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://api.openresty.org' }
    );

    my $res;
    eval {
        $res = $resty->get('/=/version/verbose');
    };
    ok !$@, 'no exception thrown';
    if ($@) { warn $@ }
    ok $res, 'res is defined';
    like Dumper($res), qr/OpenResty \d+\.\d+\.\d+ \(/, 'GET /=/version works';
}

{
    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://api.openresty.org' }
    );

    my $res;
    eval {
        $res = $resty->get('/=/model');
    };
    ok !$res, 'res is not defined as expected';
    ok $@, 'exception thrown as expected';
    like $@, qr/Login required.*?at .*?sanity\.t/s, 'GET /=/version works';
}

{
    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://api.eeeeworks.org' }
    );
    eval {
        $resty->login('agentzh.Public');
    };
    ok !$@, 'login works';

    my $res;
    eval {
        $res = $resty->get('/=/model/Post/id/1');
    };
    ok !$@, 'get the first post';
    ok $res, 'the first post is defined';
    is $res->[0]->{title}, '完美之夜，完美之旅', 'title okay';
    is $res->[0]->{author}, 'agentzh', 'title okay';
}

{
    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://api.eeeeworks.org' }
    );
    eval {
        $resty->login('agentzh.Public');
    };
    ok !$@, 'login works';

    my $res;
    eval {
        $res = $resty->get('/=/model/Post/id/1?');
    };
    ok !$@, 'get the first post';
    ok $res, 'the first post is defined';
    is $res->[0]->{title}, '完美之夜，完美之旅', 'title okay';
    is $res->[0]->{author}, 'agentzh', 'title okay';
}

{
    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://api.eeeeworks.org' }
    );
    eval {
        $resty->login('agentzh.Public');
    };
    ok !$@, 'login works';

    my $res;
    eval {
        $res = $resty->get('/=/model/Post/id/1?_password=hello');
    };
    ok $@, 'failed as expected';
    like $@, qr{GET /=/model/Post/id/1\?_password=hello: .*?"error":"Password for agentzh\.Public is incorrect\."}, 'params combined';
}

