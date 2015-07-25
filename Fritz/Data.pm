package Fritz::Data;

use Scalar::Util qw(blessed);

use Moo;
use namespace::clean;

with 'Fritz::NoError';

has raw  => ( is => 'ro', init_arg => undef );
has data => ( is => 'ro' );

# prepend 'data => ' when called without hash
# (when called with uneven list)
sub BUILDARGS
{
    my ( $class, @args ) = @_;
    
    unshift @args, "data" if @args % 2 == 1;
    
    return { @args };
};

sub BUILD
{
    my $self = shift;

    $self->{raw} = $self->data;
}

sub dump
{
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}" . blessed( $self ) . ":\n";
    print "${indent}---raw data---\n";
    print $self->raw . "\n";
    print "--------------\n";
}

1;
