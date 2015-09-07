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

=head1 NAME

Fritz::Box - main configuration and entry point for L<Fritz> distribution

=head1 SYNOPSIS

    my $fritz = Fritz::Box->new();
    $fritz->dump();

    my $fritz_ssl = Fritz::Box->new(
        upnp_url => 'https://fritz.box:49000'
    );

    my $fritz_auth = Fritz::Box->new(
        username => 'admin',
        password => 's3cr3t'
    );

=head1 DESCRIPTION

This class the global configuration state and provides discovery of
L<Fritz::Device>s.

=head1 ATTRIBUTES (read-only, defaults can be changed)

=head2 upnp_url

Default value: C<http://fritz.box:49000>

Base URL for all operations.  This must point to your device. The
default value expects a standard Fritz!Box installation with working
local DNS.

If you can't do DNS lookups for your router, use an IP address
instead.

If you have a Fritz!Box and don't know its IP, you can try
C<192.168.179.1> or C<169.254.1.1>, these adresses seem to be
hardcoded for "emergency use" after a misconfiguration.

An address starting with C<https://> enables secure communication over
SSL, but see L<Fritz/SSL> for bugs and limitations.

=cut

has upnp_url      => ( is => 'ro', default => 'http://fritz.box:49000' );

=head2 trdesc_path

Default value: C</tr64desc.xml>

The path below L</upnp_url> from where the TR064 service description
is fetched.  There should be no need to change the default.

=cut

has trdesc_path   => ( is => 'ro', default => '/tr64desc.xml' );

=head2 username

Default value: none

Sets the username to use for authentication against a device.

=cut

has username      => ( is => 'ro');

=head2 password

Default value: none

Sets the password to use for authentication against a device.

=cut

has password      => ( is => 'ro');

# internal XML::Simple instance (lazy)
has _xs           => ( is => 'lazy', init_arg => undef );

sub _build__xs {
    return XML::Simple->new(ForceArray => 1, KeyAttr => []);
}

# internal LWP::UserAgent instance (lazy)
# overwriting the default might be handy for setting proxy variables or the like
has _ua           => ( is => 'lazy');

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

=head1 METHODS

=head2 new

Creates a new L<Fritz::Box> object.  This is propably the first thing
to do when using L<Fritz>.  Expects parameters in C<key =E<gt> value>
form with the following keys to overwrite the default values:

=over

=item L</upnp_url>

=item L</trdesc_path>

=item L</username>

=item L</password>

=back

=head2 discover

Tries to discover the TR064 device at the current L</upnp_url>.
Returns a L<Fritz::Device> on success.
Accepts no parameters.

=cut

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

=head2 dump

C<print()> some information about the object.  Useful for debugging
purposes.  An optional parameter is used for indentation of the output.

=cut

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
