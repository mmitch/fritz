package Fritz::Service;

use Moo;
use namespace::clean;

with 'Fritz::NoError';

has xmltree      => ( is => 'ro' );

use constant DEVICEINFO => 'urn:dslforum-org:service:DeviceInfo:1';

use constant ATTRIBUTES => qw(
serviceType
serviceId
controlURL
eventSubURL
SCPDURL
);

for my $attr (ATTRIBUTES)
{
    has $attr => ( is => 'ro' );
}

sub BUILD
{
    my $self = shift;

    my $xml = $self->xmltree;

    for my $attr (ATTRIBUTES)
    {
	if (exists $xml->{$attr})
	{
	    $self->{$attr} = $xml->{$attr};
	}
    }
}

sub dump
{
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Service:\n";
    print "${indent}serviceType     = " . $self->{serviceType} . "\n";
    print "${indent}controlURL      = " . $self->{controlURL}  . "\n";
}

1;
