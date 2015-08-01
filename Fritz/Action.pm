package Fritz::Action;

use Moo;
use namespace::clean;

with 'Fritz::NoError';

has fritz        => ( is => 'ro' );

has xmltree      => ( is => 'ro' );
has name         => ( is => 'ro' );
has args_in      => ( is => 'ro' );
has args_out     => ( is => 'ro' );

# prepend 'xmltree => ' when called without hash
# (when called with uneven list)
sub BUILDARGS
{
    my ( $class, @args ) = @_;
    
    unshift @args, "xmltree" if @args % 2 == 1;
    
    return { @args };
};

sub BUILD
{
    my $self = shift;

    $self->{args_in}  = [];
    $self->{args_out} = [];

    my $xml = $self->xmltree;
    $self->{name} = $xml->{name}->[0];

    foreach my $arg (@{$xml->{argumentList}->[0]->{argument}})
    {
	my $dir = $arg->{direction}->[0];
	if ($dir eq 'out')
	{
	    push @{$self->{args_out}}, $arg->{name}->[0];
	}
	elsif ($dir eq 'in')
	{
	    push @{$self->{args_in}}, $arg->{name}->[0];
	}
	else
	{
	    # TODO throw error - but how?  we don't return an object
	}
    }
}

sub dump
{
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Action:\n";
    print "${indent}name     = " . $self->name     . "\n";
    print "${indent}args_in  = " . join(', ', @{$self->args_in})  . "\n";
    print "${indent}args_out = " . join(', ', @{$self->args_out}) . "\n";
}

1;
