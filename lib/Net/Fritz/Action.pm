use strict;
use warnings;
# Copyright (C) 2015  Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL v2 or later.

package Net::Fritz::Action;
# ABSTRACT: represents a TR064 action


use Moo;

with 'Net::Fritz::IsNoError';

=head1 SYNOPSIS

    my $fritz    = Net::Fritz::Box->new();
    my $device   = $fritz->discover();
    my $service  = $device->get_service('DeviceInfo:1');
    my $action   = $device->action_hash('GetSecurityPort');

    # show all data
    $action->dump();

=head1 DESCRIPTION

This class represents a TR064 action belonging to a
L<Net::Fritz::Service>.  An action is a rather boring object
containing the input/output parameter names as well as the action
name.  To call (execute) an action, use L<Net::Fritz::Service/call>.

=head1 ATTRIBUTES (read-only)

=head2 xmltree

A complex hashref containing most information about this
L<Net::Fritz::Action>.  This is the parsed form of the part from the
L<Net::Fritz::Service/scpd> XML that describes this action.

=cut

has xmltree      => ( is => 'ro' );

=head2 name

The name of this action as a string.  This is used to identify the
action in a L<Net::Fritz::Service/call>.

=cut
    
has name         => ( is => 'lazy', init_arg => undef );

sub _build_name {
    my $self = shift;
    return $self->xmltree->{name}->[0];
}

=head2 args_in

An arrayref containing the names of all input parameters for this
action.  These parameters must be present in a L<Net::Fritz::Service/call>.

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
action.  These parameters will be present in the
L<Net::Fritz::Data/data> response to a L<Net::Fritz::Service/call>.

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

See L<Net::Fritz::IsNoError/error>.

=head1 METHODS

=head2 new

Creates a new L<Net::Fritz::Action> object.  You propably don't have
to call this method, it's mostly used internally.  Expects parameters
in C<key =E<gt> value> form with the following keys:

=over

=item I<xmltree>

action information in parsed XML format

=back

With only one parameter (in fact: any odd value of parameters), the
first parameter is automatically mapped to I<xmltree>.

=for Pod::Coverage BUILDARGS

=cut

sub BUILDARGS {
    my ( $class, @args ) = @_;

    unshift @args, "xmltree" if @args % 2 == 1;

    return { @args };
};

=head2 dump(I<indent>)

Returns some preformatted multiline information about the object.
Useful for debugging purposes, printing or logging.  The optional
parameter I<indent> is used for indentation of the output by
prepending it to every line.

=cut

sub dump {
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    my $text = "${indent}Net::Fritz::Action:\n";
    $indent .= '  ';
    $text .= "${indent}name     = " . $self->name     . "\n";
    $text .= "${indent}args_in  = " . join(', ', @{$self->args_in})  . "\n";
    $text .= "${indent}args_out = " . join(', ', @{$self->args_out}) . "\n";

    return $text;
}

=head2 errorcheck

See L<Net::Fritz::IsNoError/errorcheck>.

=head1 SEE ALSO

See L<Net::Fritz> for general information about this package,
especially L<Net::Fritz/INTERFACE> for links to the other classes.

=cut

1;
