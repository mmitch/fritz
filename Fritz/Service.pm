package Fritz::Service;

use LWP::UserAgent;
use SOAP::Lite; # +trace => [ transport => sub { print $_[0]->as_string } ];

use Fritz::Data::Text;
use Fritz::Data::XML;

use Moo;
use namespace::clean;

with 'Fritz::NoError';

has fritz        => ( is => 'ro' );

has xmltree      => ( is => 'ro' );
has scpd         => ( is => 'lazy' );
has action_hash  => ( is => 'lazy' );

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

sub _build_scpd
{
    my $self    = shift;

    my $url = $self->fritz->upnp_url . $self->SCPDURL;

    my $ua = LWP::UserAgent->new();
    my $response = $ua->get($url);

    if ($response->is_success)
    {
	$self->{scpd} = Fritz::Data::XML->new($response->decoded_content);
    }
    else
    {
	$self->{scpd} = Fritz::Error->new($response->status_line);
    }
}

sub _build_action_hash
{
    my $self    = shift;

    my $scpd = $self->scpd;

    if ($scpd->error)
    {
	$self->{action_hash} = {};
    }
    else
    {
	$self->{action_hash} = $scpd->data->{actionList}->{action};
    }
}

sub call
{
    my $self    = shift;
    my $action  = shift;

    if (! exists $self->action_hash->{$action})
    {
	return Fritz::Error->new("unknown action $action");
    }

    my $url = $self->fritz->upnp_url . $self->controlURL;

    my $soap = SOAP::Lite->new(
	proxy    => $url,
	uri      => $self->serviceType,
	readable => 1 # TODO: remove this
	);

    # write proper error handler, SOAP::Lite just dies on transport error (eg. 401 Unauthorized)
    my $som = $soap->call($action);

    if ($som->fault)
    {
	return Fritz::Error->new($som->fault->faultstring);
    }
    else
    {
	return Fritz::Data::Text->new($som->result);
    }
}

sub dump
{
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Service:\n";
    print "${indent}serviceType     = " . $self->serviceType . "\n";
    print "${indent}controlURL      = " . $self->controlURL  . "\n";
    print "${indent}SCPDURL         = " . $self->SCPDURL     . "\n";
}

1;
