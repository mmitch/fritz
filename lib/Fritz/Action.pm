package Fritz::Action;
use strict;
use warnings;

use Moo;
use namespace::clean;

with 'Fritz::IsNoError';

=head1 NAME

Fritz::Action - represents a TR064 action

=head1 SYNOPSIS

    my $fritz    = Fritz::Box->new();
    my $device   = $fritz->discover();
    my $service  = $device->get_service('DeviceInfo:1');
    my $action   = $device->action_hash('GetSecurityPort');

    # show all data
    $service->dump();

=head1 DESCRIPTION

This class represents a TR064 action belonging to a L<Fritz::Service>.
An action is a rather boring object containing some data on parameters.
To call (execute) an action, use L<Fritz::Service/call>.

=head1 ATTRIBUTES (read-only)

=head2 fritz

A L<Fritz::Box> instance containing the current configuration
information (device address, authentication etc.).

=cut

has fritz        => ( is => 'ro' );

=head2 xmltree

A complex hashref containing most information about this
L<Fritz::Action>.  This is the parsed form of the part from the
L<Fritz::Service/scpd> XML that describes this action.

=cut

has xmltree      => ( is => 'ro' );

=head2 name

The name of this action as a string.  This is used to identify the
action in a L<Fritz::Service/call>.

=cut
    
has name         => ( is => 'lazy', init_arg => undef );

sub _build_name {
    my $self = shift;
    return $self->xmltree->{name}->[0];
}

=head2 args_in

An arrayref containing the names of all input parameters for this
action.  These parameters must be present on a L<Fritz::Service/call>.

=cut

has args_in      => ( is => 'lazy', init_arg => undef );

sub _build_args_in {
    my $self = shift;
    my @args;

    # TODO convert to grep
    foreach my $arg (@{$self->xmltree->{argumentList}->[0]->{argument}}) {
	if ($arg->{direction}->[0] eq 'in') {
	    push @args, $arg->{name}->[0];
	}
    }

    return \@args;
}

=head2 args_out

An arrayref containing the names of all output parameters of this
action.  These parameters will be present in the L<Fritz::Data/data>
response to a L<Fritz::Service/call>.

=cut

has args_out     => ( is => 'lazy', init_arg => undef );

sub _build_args_out {
    my $self = shift;
    my @args;

    # TODO convert to grep
    foreach my $arg (@{$self->xmltree->{argumentList}->[0]->{argument}}) {
	if ($arg->{direction}->[0] eq 'out') {
	    push @args, $arg->{name}->[0];
	}
    }

    return \@args;
}

=head2 error

See L<Fritz::IsNoError/error>.

=head1 METHODS

=head2 new

Creates a new L<Fritz::Action> object.  You propably don't have to call
this method, it's mostly used internally.  Expects parameters in C<key
=E<gt> value> form with the following keys:

=over

=item I<fritz>

L<Fritz::Box> configuration object

=item I<xmltree>

action information in parsed XML format

=back

With only one parameter (in fact: any odd value of parameters), the
first parameter is automatically mapped to I<xmltree>.

=cut

sub BUILDARGS {
    my ( $class, @args ) = @_;

    unshift @args, "xmltree" if @args % 2 == 1;

    return { @args };
};

=head2 dump(I<indent>)

C<print()> some information about the object.  Useful for debugging
purposes.  The optional parameter I<indent> is used for indentation of
the output by prepending it to every line.

=cut

sub dump {
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Action:\n";
    print "${indent}name     = " . $self->name     . "\n";
    print "${indent}args_in  = " . join(', ', @{$self->args_in})  . "\n";
    print "${indent}args_out = " . join(', ', @{$self->args_out}) . "\n";
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
