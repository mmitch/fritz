package Fritz;

use LWP::UserAgent;
use XML::Simple;

use Fritz::Error;
use Fritz::Device;

use Moo;
use namespace::clean;

has upnp_url      => ( is => 'ro', default => 'http://fritz.box:49000' );
has trdesc_path   => ( is => 'ro', default => '/tr64desc.xml' );

sub discover
{
    my $self = shift;

    my $url = $self->upnp_url . $self->trdesc_path;
    
    my $ua = LWP::UserAgent->new();
    my $response = $ua->get($url);
    
    if ($response->is_success)
    {
	return Fritz::Device->new(
	    xmltree => XMLin($response->decoded_content)->{device},
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
