package Fritz;

use LWP::UserAgent;
use XML::Simple;
use Fritz::Error;
use Fritz::Device;

use Moo;
use namespace::clean;

has discover_base => ( is => 'ro' );
has discover_port => ( is => 'ro', default => '49000' );
has device_base   => ( is => 'ro', default => 'http://fritz.box' );
has trdesc_path   => ( is => 'ro', default => 'tr64desc.xml' );

sub BUILD
{
    my $self = shift;

    if (not defined $self->discover_base)
    {
	$self->{discover_base} = $self->device_base; # or better set this attribute to 'rwp' instead of 'ro'?
    }
}

sub discover
{
    my $self = shift;

    my $url = sprintf('%s:%d/%s',
		      $self->discover_base,
		      $self->discover_port,
		      $self->trdesc_path);
    
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
    print "${indent}device_base   = " . $self->device_base   . "\n";
    print "${indent}discover_base = " . $self->discover_base . "\n";
    print "${indent}discover_port = " . $self->discover_port . "\n";
    print "${indent}trdesc_path   = " . $self->trdesc_path   . "\n";
}

1;
