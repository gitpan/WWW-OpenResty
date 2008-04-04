package WWW::OpenResty::Simple;

use strict;
use warnings;

use Carp 'croak';
use JSON::XS ();
use base 'WWW::OpenResty';
use Params::Util qw( _HASH );

our $VERSION = '0.05';
our $json_xs = JSON::XS->new->utf8->allow_nonref;

sub request {
    my $self = shift;
    my $data = $_[0];
    my $meth = $_[1];
    my $url = $_[2];
    if ($data && ref $data) {
        $_[0] = $json_xs->encode($data);
    }
    my $retries = $self->{retries} || 0;
    my $i = 0;
    while (1) {
        my $res = $self->SUPER::request(@_);
        if ($res->is_success) {
            my $json = $res->content;
            #$json =~ s/\n+$//gs;
            my $data = $json_xs->decode($json);
            if (_HASH($data) && defined $data->{success} && $data->{success} == 0) {
                if ($i >= $retries) {
                    croak "$meth $url: $json";
                } else {
                    warn "Retrying...\n";
                }
            } else {
                return $data;
            }
        } else {
            my $status_line = $res->status_line;
            if ($i >= $retries) {
                croak "$meth $url: $status_line";
            } else {
                warn "Retrying...\n";
            }
        }
    } continue { $i++ }
}

sub has_model {
    my ($self, $model) = @_;
    my $res;
    eval {
        $res = $self->get("/=/model/$model");
    };
    if ($@) {
        if ($@ =~ /Model .*? not found/i) {
            return undef;
        }
        die $@;
    }
    return _HASH($res) && $res->{name} eq $model;
}

sub has_view {
    my ($self, $view) = @_;
    my $res;
    eval {
        $res = $self->get("/=/view/$view");
    };
    if ($@) {
        if ($@ =~ /View .*? not found/i) {
            return undef;
        }
        die $@;
    }
    return _HASH($res) && $res->{name} eq $view;
}

1;
__END__

=head1 NAME

WWW::OpenResty::Simple - A simple wrapper around WWW::OpenResty

=head1 VERSION

This document describes C<WWW::OpenResty::Simple> 0.05 released on April 4,
2008.

=head1 SYNOPSIS

    use WWW::OpenResty::Simple;

    my $resty = WWW::OpenResty::Simple->new(
        {
            server => 'http://resty.eeeeworks.org',
            retries => 1 # retry once when failing (default to 0),
        }
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
like C<login>, C<get>, C<post>, C<put>, and C<delete>, as well as its own:
C<has_view> and C<has_model>.

Unlike the methods of L<WWW::OpenResty> returning a raw L<HTTP::Response>
object, the methods in this class always return the Perl structure
directly. That is, it automatically load the JSON literals sent by
the server if no error occurs; it throws an exception out otherwise.

Also, the C<$content> parameter in the C<post> and C<put> methods
are plain Perl data structures rather than string literals. This class will
automatically serialize the data structure into JSON before sending
out via the HTTP protocol.

=head1 METHODS

=over

=item C<< $bool = $resty->has_view($view_name) >>

Check if the view given exists.

=item C<< $bool = $resty->has_model($model_name) >>

Check if the model given exists.

=back

=head1 AUTHOR

agentzh C<< <agentzh at yahoo.cn> >>

=head1 COPYRIGHT

Copyright (c) 2008 by Yahoo! China EEEE Works, Alibaba Inc.

=head1 License

The "MIT" License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

