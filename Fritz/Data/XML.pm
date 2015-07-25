package Fritz::Data::XML;

use XML::Simple;

use Moo;
use namespace::clean;

extends 'Fritz::Data';

sub BUILD
{
    my $self = shift;

    $self->{raw} = $self->data;
    $self->{data} = XMLin( $self->data );
}

1;
