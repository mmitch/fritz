package Fritz;

use LWP::UserAgent;
use XML::Simple qw(:strict);

use Fritz::Error;
use Fritz::Device;

use Moo;
use namespace::clean;

with 'Fritz::NoError';

has upnp_url      => ( is => 'ro', default => 'http://fritz.box:49000' );
has trdesc_path   => ( is => 'ro', default => '/tr64desc.xml' );
has username      => ( is => 'ro');
has password      => ( is => 'ro');
has _xs           => ( is => 'ro', default => sub { return XML::Simple->new(ForceArray => 1, KeyAttr => []) }, init_arg => undef );

sub discover
{
    my $self = shift;

    my $url = $self->upnp_url . $self->trdesc_path;
    
    my $ua = LWP::UserAgent->new();
    my $response = $ua->get($url);
    
    if ($response->is_success)
    {
	return Fritz::Device->new(
	    xmltree => $self->_xs->parse_string($response->decoded_content)->{device}->[0],
	    fritz   => $self
	    );
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

    print "${indent}Fritz:\n";
    $indent .= '  ';
    print "${indent}upnp_url    = " . $self->upnp_url    . "\n";
    print "${indent}trdesc_path = " . $self->trdesc_path . "\n";
}

1;
