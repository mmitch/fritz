package Fritz::Action;

use LWP::UserAgent;
use SOAP::Lite; # +trace => [ transport => sub { print $_[0]->as_string } ];

use Fritz::Data::Text;
use Fritz::Data::XML;

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

    # b0rk, XML tree is shaped differently when there is only one argument :/
    # remedy this
    # TODO: nearly the same code is in Fritz::Service - is one fix enough?
    my @keys = keys %{$xml->{argumentList}->{argument}};
    if (@keys == 3
	and ref( $xml->{argumentList}->{argument}->{$keys[0]} ) eq '')
    {
	my $name = $xml->{argumentList}->{argument}->{name};
	$xml->{argumentList}->{argument} = {
	    $name => $xml->{argumentList}->{argument}
	};
	@keys = ($name);
    }

    foreach my $arg (@keys)
    {
	my $dir = $xml->{argumentList}->{argument}->{$arg}->{direction};
	if ($dir eq 'out')
	{
	    push @{$self->{args_out}}, $arg;
	}
	elsif ($dir eq 'in')
	{
	    push @{$self->{args_in}}, $arg;
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
