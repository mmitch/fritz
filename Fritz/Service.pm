package Fritz::Service;

use LWP::UserAgent;
use SOAP::Lite; # +trace => [ transport => sub { print $_[0]->as_string } ];
use XML::Simple;

use Moo;
use namespace::clean;

with 'Fritz::NoError';

has fritz        => ( is => 'ro' );

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

sub call
{
    my $self    = shift;
    my $method  = shift;

    my $url = $self->fritz->upnp_url . $self->controlURL;

    my $soap = SOAP::Lite->new(
	proxy => $url,
	uri    => $self->serviceType,
	readable => 1 # TODO: remove this
	);

    my $som = $soap->call('GetSecurityPort');

    if ($som->fault)
    {
	return Fritz::Error->new($som->faultstring);
    }
    else
    {
	return $som->result; # TODO: create result class?
    }
}

sub get_SCPD
{
    my $self    = shift;

    my $url = $self->fritz->upnp_url . $self->SCPDURL;

    my $ua = LWP::UserAgent->new();
    my $response = $ua->get($url);

    if ($response->is_success)
    {
	return XMLin($response->decoded_content); # TODO: create SCPD class?
    }
    else
    {
	return Fritz::Error->new($response->status_line)
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
    print "${indent}SCPDURL         = " . $self->{SCPDURL}     . "\n";
}

1;
