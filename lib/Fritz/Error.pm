package Fritz::Error;
use strict;
use warnings;

# TODO: use a global configuration option to make every call to
#       Fritz::Error->new an immediately fatal error?

use Moo;
use namespace::clean;

=head1 NAME

Fritz::Error - wraps any error from the L<Fritz> modules

=head1 SYNOPSIS

    $root_device = Fritz::Box->new->discover;
    $root_device->errorcheck;

or

    $root_device = Fritz::Box->new->discover;
    if ($root_device->error) {
        die "error: " . $root_device->error;
    }

=head1 DESCRIPTION

Whenever any of the L<Fritz> modules detects an error, it returns an
L<Fritz::Error> object.  All valid (non-error) objects also implement
C<error> and C<errorcheck> via the role L<Fritz::IsNoError>, so
calling both methods always works for any L<Fritz> object.

If you want your code to just C<die()> on any error, call
C<$obj->errorcheck> on every returned object (see first example above).

If you just want to check for an error and handle it by yourself, call
C<$obj-E<gt>error>.  All non-errors will return C<0> (see second example above).

You don't have to check for errors at all, but then you might run into
problems when you want to invoke methods on an L<Fritz::Error> object
that don't exist (because you expected to get eg. an L<Fritz::Service>
object instead).

=head1 ATTRIBUTES (read-only)

=head2 error

Contains the error message as a string.  Don't set this to anything
resembling false or you will trick your tests.

=cut

has error => ( is => 'ro', default => 'generic error' );

=head1 METHODS

=head2 new

Creates a new L<Fritz::Error> object.  You propably don't have to call
this method, it's mostly used internally.  Expects parameters in C<key
=E<gt> value> form with the following keys:

=over

=item I<error>

set the error message

=back

With only one parameter (in fact: any odd value of parameters), the
first parameter is automatically mapped to I<error>.

=cut

sub BUILDARGS {
    my ( $class, @args ) = @_;
    
    unshift @args, "error" if @args % 2 == 1;
    
    return { @args };
};

=head2 errorcheck
    
Immediately C<die()>, printing the error text.

=cut

sub errorcheck {
    my $self = shift;
    die "Fritz::Error: " . $self->error. "\n";
}

=head2 dump

C<print()> some information about the object.  Used for debugging
purposes.

=cut

sub dump {
    my $self = shift;

    print "Fritz::Error: " . $self->error . "\n";
}

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
