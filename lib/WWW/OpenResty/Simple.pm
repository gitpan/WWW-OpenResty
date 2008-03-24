package WWW::OpenResty::Simple;

use strict;
use warnings;

#use Carp 'confess';
use JSON::Syck ();
use base 'WWW::OpenResty';
use Params::Util qw( _HASH );

our $VERSION = '0.02';

sub request {
    my $self = shift;
    my $data = $_[0];
    my $meth = $_[1];
    my $url = $_[2];
    if ($data && ref $data) {
        $_[0] = JSON::Syck::Dump($data);
    }
    my $res = $self->SUPER::request(@_);
    if ($res->is_success) {
        my $json = $res->content;
        my $data = JSON::Syck::Load($json);
        if (_HASH($data) && defined $data->{success} && $data->{success} == 0) {
            die "$meth $url: $json\n";
        }
        return $data;
    }
    die "$meth $url: ", $res->status_line, "\n";
}

1;
__END__

=head1 NAME

WWW::OpenResty::Simple - A simple wrapper around WWW::OpenResty

=head1 VERSION

This document describes C<WWW::OpenResty::Simple> 0.02 released on Mar 19,
2008.

=head1 SYNOPSIS

    use WWW::OpenResty::Simple;

    my $resty = WWW::OpenResty::Simple->new(
        { server => 'http://resty.eeeeworks.org' }
    );

    my $res;
    eval {
        $res = $resty->get('/=/version');
    };
    if ($@) { die $@ }
    print Dumper($res);
    # Got:
    # $VAR1 = 'OpenResty 0.1.0 (revision 973) with the ...'

    # The following requires privileges...
    $resty->login('account.Role', 'password');
    $res = $resty->post(
        '/=/model/Comments/~/~',
        {
            author:"agentzh",
            title:"Great post!",
            body:"clapping..."
        }
    );

    # Update the comment with ID 3:
    $res = $resty->put(
        '/=/model/Comments/id/3',
        { title: "New title" }
    );

    # Remove the comment with the ID 3:
    $res = $resty->delete('/=/model/Comments/id/3');

=head1 DESCRIPTION

This class inherits from L<WWW::OpenResty>, which does automatic JSON
serialization for input and output data. In addition, it croaks on
errors returned from the OpenResty server.

=head1 METHODS

This class exposes all the methods of its parent class, L<WWW:OpenResty>,
like C<login>, C<get>, C<post>, C<put>, and C<delete>.

Unlike the methods of L<WWW::OpenResty> returning a raw L<HTTP::Response>
object, the methods in this class always return the Perl structure
directly. That is, it automatically load the JSON literals sent by
the server if no error occurs; it throws an exception out otherwise.

Also, the C<$content> parameter in the C<post> and C<put> methods
are plain Perl data structures rather than string literals. This class will
automatically serialize the data structure into JSON before sending
out via the HTTP protocol.

=head1 AUTHOR

agentzh C<< <agentzh at yahoo.cn> >>

=head1 COPYRIGHT

Copyright (c) 2008 by Yahoo! China EEEE Works, Alibaba Inc.

=head1 License

The "MIT" License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

