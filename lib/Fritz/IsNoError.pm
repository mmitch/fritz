package Fritz::IsNoError;
use strict;
use warnings;

use Moo::Role;
use namespace::clean;

=head1 NAME

Fritz::IsNoError - a L<Moo::Role> discerning all other L<Fritz>
objects from an L<Fritz::Error> object

=head1 SYNOPSIS

    $root_device = Fritz::Box->new->discover;
    $root_device->errorcheck;

or

    $root_device = Fritz::Box->new->discover;
    if ($root_device->error) {
        die "error: " . $root_device->error;
    }

=head1 DESCRIPTION

All valid (non-error) L<Fritz> classes do the L<Fritz::IsNoError>
role, the only exception being of course) L<Fritz::Error>.  B<All>
L<Fritz> objects thus support C<error> and C<errorcheck>

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

Returns an empty string to pass any C<if($obj-E<gt>error) { ... }> checks.

=cut

has error => ( is => 'ro', default => '' );

=head1 METHODS

=head2 errorcheck

A no-op, so calling C<$obj-E<gt>errorcheck> just succeeds and carries on.

=cut

sub errorcheck {
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
