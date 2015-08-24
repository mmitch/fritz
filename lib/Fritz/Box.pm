package Fritz::Box;
use strict;
use warnings;

use LWP::UserAgent;
use XML::Simple qw(:strict);

use Fritz::Error;
use Fritz::Device;

use Moo;
use namespace::clean;

use version; our $VERSION = qv('0.0.1');

with 'Fritz::IsNoError';

has upnp_url      => ( is => 'ro', default => 'http://fritz.box:49000' );
has trdesc_path   => ( is => 'ro', default => '/tr64desc.xml' );
has username      => ( is => 'ro');
has password      => ( is => 'ro');
has _xs           => ( is => 'lazy', init_arg => undef );
has _ua           => ( is => 'lazy');

sub _build__xs {
    return XML::Simple->new(ForceArray => 1, KeyAttr => []);
}

sub _build__ua {
    # Depending on your SSL setup (propably which SSL modules LWP::UserAgent uses
    # for transport), this is also needed to disable certificate checks.
    # I have one machine that needs it and another that doesn't.
    $ENV{HTTPS_DEBUG} = 1;
    
    my $ua = LWP::UserAgent->new();
    # disable SSL certificate checks, Fritz!Box has no verifiable SSL certificate
    $ua->ssl_opts(verify_hostname => 0 ,SSL_verify_mode => 0x00);
    
    return $ua;
}

sub discover {
    my $self = shift;

    my $url = $self->upnp_url . $self->trdesc_path;
    
    my $response = $self->_ua->get($url);
    
    if ($response->is_success) {
	return Fritz::Device->new(
	    xmltree => $self->_xs->parse_string($response->decoded_content)->{device}->[0],
	    fritz   => $self
	    );
    }
    else {
	return Fritz::Error->new($response->status_line)
    }
}

sub dump {
    my $self = shift;
    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz:\n";
    $indent .= '  ';
    print "${indent}upnp_url    = " . $self->upnp_url    . "\n";
    print "${indent}trdesc_path = " . $self->trdesc_path . "\n";
}

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 by  Christian Garbs <mitch@cgarbs.de>
Licensed under GNU GPL v2 or later.

=head1 AUTHOR

Christian Garbs <mitch@cgarbs.de>

=head1 SEE ALSO

See L<Fritz> for general information about this package, especially
L<Fritz/INTERFACE> for links to the other classes.

=cut

1;
