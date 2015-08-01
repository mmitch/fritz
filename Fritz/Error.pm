package Fritz::Error;

use Moo;
use namespace::clean;

has error => ( is => 'ro', default => 'generic error' );

# prepend 'error => ' when called without hash
# (when called with uneven list)
sub BUILDARGS
{
    my ( $class, @args ) = @_;
    
    unshift @args, "error" if @args % 2 == 1;
    
    return { @args };
};

sub dump
{
    my $self = shift;

    print "Fritz::Error: " . $self->error . "\n";
}

sub errorcheck
{
    my $self = shift;
    die "Fritz::Error: " . $self->error. "\n";
}

1;
