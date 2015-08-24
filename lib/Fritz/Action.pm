package Fritz::Action;
use strict;
use warnings;

use Moo;
use namespace::clean;

with 'Fritz::IsNoError';

has fritz        => ( is => 'ro' );

has xmltree      => ( is => 'ro' );
has name         => ( is => 'lazy', init_arg => undef );
has args_in      => ( is => 'lazy', init_arg => undef );
has args_out     => ( is => 'lazy', init_arg => undef );

# prepend 'xmltree => ' when called without hash
# (when called with uneven list)
sub BUILDARGS {
    my ( $class, @args ) = @_;
    
    unshift @args, "xmltree" if @args % 2 == 1;
    
    return { @args };
};

sub _build_name {
    my $self = shift;
    return $self->xmltree->{name}->[0];
}

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

sub dump {
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Action:\n";
    print "${indent}name     = " . $self->name     . "\n";
    print "${indent}args_in  = " . join(', ', @{$self->args_in})  . "\n";
    print "${indent}args_out = " . join(', ', @{$self->args_out}) . "\n";
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
