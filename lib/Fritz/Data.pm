package Fritz::Data;
use strict;
use warnings;

use Scalar::Util qw(blessed);

use Moo;
use namespace::clean;

with 'Fritz::IsNoError';

=head1 NAME

Fritz::Data - wraps various response data 

=head1 SYNOPSIS

    my $fritz    = Fritz::Box->new();
    my $device   = $fritz->discover();
    my $service  = $device->find_service('DeviceInfo:1');
    my $response = $service->call('GetSecurityPort');

    # $response is Fritz::Data
    printf "SSL communication port is %d\n",
           $response->data->{NewSecurityPort};


    my $service_list = $device->find_service_names('DeviceInfo:1');

    # service_list is Fritz::Data
    printf "%d services found\n",
           scalar @{$service_list->data};

=head1 DESCRIPTION

This class wraps the return data from a L<Fritz::Service> call.  This
is only done for consistent error checks: L<Fritz::Data>
USES/CONSUMES/WHADDYACALLIT the role L<Fritz::IsNoError>, so it is
possible to check for errors during the service call with
C<$response-E<gt>error> and C<$response-E<gt>errorcheck> (see
L<Fritz::Error> for details).

Apart from that the response data from the service call is passed
through unaltered, so you have to know with which data type the
services answers.

This wrapper class is also used in some other methods that return
things that need to be error-checkable, like
L<Fritz::Device/find_service_names>.

=head1 ATTRIBUTES (read-only)

=head2 data

Returns the response data of the service call.  For lists and hashes,
this will be a reference.

=cut

has data => ( is => 'ro' );

=head2 error

See L<Fritz::IsNoError/error>.

=head1 METHODS

=head2 new

Creates a new L<Fritz::Data> object.  You propably don't have to call
this method, it's mostly used internally.  Expects parameters in C<key
=E<gt> value> form with the following keys:

=over

=item I<data>

set the data to hold

=back

With only one parameter (in fact: any odd value of parameters), the
first parameter is automatically mapped to I<data>.

=cut

# prepend 'data => ' when called without hash
# (when called with uneven list)
sub BUILDARGS {
    my ( $class, @args ) = @_;
    
    unshift @args, "data" if @args % 2 == 1;
    
    return { @args };
};

=head2 get

Kind of an alias for C<$response->data>: Returns the L<data|/data> attribute.

=cut

sub get {
    my $self = shift;

    return $self->data;
}

=head2 dump(I<indent>)

C<print()> some information about the object.  Useful for debugging
purposes.  The optional parameter I<indent> is used for indentation of
the output by prepending it to every line.

=cut

sub dump {
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}" . blessed( $self ) . ":\n";
    print "${indent}----data----\n";
    print $self->data . "\n";
    print "------------\n";
}

=head2 errorcheck

See L<Fritz::IsNoError/errorcheck>.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 by  Christian Garbs <mitch@cgarbs.de>
Licensed under GNU GPL v2 or later.

=head1 AUTHOR

Christian Garbs <mitch@cgarbs.de>

=head1 SEE ALSO

See L<Fritz> for general information about this package, especially
L<Fritz/INTERFACE> for links to the other classes.

=cut

1;
