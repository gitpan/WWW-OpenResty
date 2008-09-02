package WWW::OpenResty;

use strict;
use warnings;

#use Smart::Comments;
use Carp qw(croak);
use Params::Util qw( _HASH0 );
use LWP::UserAgent;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

our $VERSION = '0.08';

sub new {
    ### @_
    my $class = ref $_[0] ? ref shift : shift;
    my $params = _HASH0(shift @_) or croak "Invalid params";
    ### $params
    my $server = delete $params->{server} or
        croak "No server specified.";
    if ($server !~ m{^\w+://}) {
        $server = "http://$server";
    }
    my $ignore_dup_error = delete $params->{ignore_dup_error};
    my $timer = delete $params->{timer};
    my $retries = delete $params->{retries};
    my $ua = LWP::UserAgent->new;
    $ua->cookie_jar({ file => "cookies.txt" });
    bless {
        server => $server,
        ua => $ua,
        timer => $timer,
        retries => $retries,
        ignore_dup_error => $ignore_dup_error,
    }, $class;
}

sub content_type {
    $_[0]->{content_type} = $_[1];
}

sub login {
    my ($self, $user, $password) = @_;
    if ($password) {
        $password = md5_hex($password);
        return $self->get("/=/login/$user/$password?_use_cookie=1");
    }
    $self->{_user} = $user;
}

sub get {
    my $self = shift;
    $self->request(undef, 'GET', @_);
}

sub post {
    my $self = shift;
    my $content = pop;
    $self->request($content, 'POST', @_);
}

sub put {
    my $self = shift;
    my $content = pop;
    $self->request($content, 'PUT', @_);
}

sub delete {
    my $self = shift;
    $self->request(undef, 'DELETE', @_);
}

sub request {
    my ($self, $content, $method, $url, $params) = @_;
    !defined $params or _HASH0($params) or
        croak "Params must be a hash: ", Dumper($params);
    !ref $url or croak "URL is of the wrong type: ", Dumper($url);
    $params ||= {};
    if ($self->{_user}) {
        $params->{_user} ||= $self->{_user};
    }
    my @params;
    while (my ($key, $val) = each %$params) {
        push @params, "$key=$val";
    }
    if ($url =~ /\?$/) {
        $url .= join '&', @params;
    } elsif ($url =~ /\?/) {
        $url .= "&" . join '&', @params;
    } else {
        $url .= "?" . join '&', @params;
    }
    my $type = $self->{content_type};
    $type ||= 'text/plain';
    if ($url !~ /^http:\/\//) {
        $url = $self->{server} . $url;
    }
    my $req = HTTP::Request->new($method);
    $req->header('Content-Type' => $type);
    $req->header('Accept', '*/*');
    $req->url($url);
    if ($content) {
        if ($method eq 'GET' or $method eq 'HEAD') {
            croak "HTTP 1.0/1.1 $method request should not have content: $content";
        }

        $req->content($content);
    } elsif ($method eq 'POST' or $method eq 'PUT') {
        $req->header('Content-Length' => 0);
    }
    my $timer = $self->{timer};
    my $ua = $self->{ua};
    $timer->start($method) if $timer;
    my $res = $ua->request($req);
    $timer->stop($method) if $timer;
    return $res;
}


1;
__END__

=head1 NAME

WWW::OpenResty - Client-side library for OpenResty servers

=head1 VERSION

This document describes C<WWW::OpenResty> 0.08 released on September 2, 2008.

=head1 SYNOPSIS

    use WWW::OpenResty;

    my $resty = WWW::OpenResty->new(
        { server => 'http://resty.eeeeworks.org' }
    );

    # returns an HTTP::Response object
    my $res = $resty->get('/=/version');
    if ($res->is_success) {
        print $res->content;
    } else {
        die $res->status_line;
    }

    $res = $resty->get(
        '/=/model/Post/~/~',
        { user => 'agentzh.Public', offset => 3, limit => 10 }
    );

    $resty->login($user, $password);
    $resty->delete('/=/model');  # delete all the models
    $resty->delete('/=/model/Foo');  # delete the Foo model
    $res = $resty->get('/=/role');  # get the role list

    # create model Post
    $res = $resty->post(
        '/=/model/Post.json',
        '{
            description: "Blog post",
            columns: [
                { name: "title", label: "Post title" },
                { name: "content", label: "Post content" },
                { name: "author", label: "Post author" },
                { name: "created", default: ["now()"],
                type: "timestamp(0) with time zone",
                label: "Post creation time" },
                { name: "comments", label: "Number of comments",
                default: 0 }
            ]
        }'
    );

    # modify the label for the model column "title":
    $res = $resty->put('/=/model/Post/title', '{ label: "blah!" }');

=head1 DESCRIPTION

C<WWW::OpenResty> wraps an L<LWP::UserAgent> object and serves as a client
for L<OpenResty> servers.

This module is still under ative development and we definitely need more
POD and tests. We're just following the "release early, release often" guideline. Please check back often :P

But most of the time, you just need its subclass L<WWW::OpenResty::Simple>
which provides a more friendly interface and with automatic error checking support.

=head1 METHODS

=over

=item C<< $res = $obj->login($user, $password) >>

=item C<< $res = $obj->get($url) >>

=item C<< $res = $obj->get($url, $url_params) >>

=item C<< $res = $obj->post($url, $content) >>

=item C<< $res = $obj->post($url, $url_params, $content) >>

=item C<< $res = $obj->put($url, $content) >>

=item C<< $res = $obj->put($url, $url_params, $content) >>

=item C<< $res = $obj->delete($url) >>

=item C<< $res = $obj->delete($url, $url_params) >>

=back

=head1 SOURCE CONTROL

For the very latest version of this module, check out the source from
the SVN repos below:

L<http://svn.openfoundry.org/wwwopenresty>

There is anonymous access to all. If you'd like a commit bit, please let
us know. :)

=head1 BUGS

Please report bugs or send wish-list to
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-OpenResty>.

=head1 SEE ALSO

L<OpenResty>, L<HTTP::Response>.

=head1 AUTHOR

agentzh C<< <agentzh at yahoo.cn> >>

=head1 COPYRIGHT

Copyright (c) 2008 by Yahoo! China EEEE Works, Alibaba Inc.

=head1 License

The "MIT" License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

