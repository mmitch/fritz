#!perl
use Test::More tests => 23;
use warnings;
use strict;

use Test::Mock::LWP::Dispatch;
use HTTP::Response;

BEGIN { use_ok('Fritz::Box') };


### public tests

# new()
my $box = new_ok( 'Fritz::Box' );
is( $box->error, '', 'get Fritz::Box instance');
isa_ok( $box, 'Fritz::Box' );
is( $box->upnp_url,    'http://fritz.box:49000', 'Fritz::Box->upnp_url'    );
is( $box->trdesc_path, '/tr64desc.xml',          'Fritz::Box->trdesc_path' );
is( $box->username,    undef,                    'Fritz::Box->username'    );
is( $box->password,    undef,                    'Fritz::Box->password'    );

# new() with parameters
$box = new_ok( 'Fritz::Box',
	       [ upnp_url    => 'U1',
		 trdesc_path => 'T2',
		 username    => 'U3',
		 password    => 'P4'
	       ]
    );
is( $box->error, '', 'get Fritz::Box instance');
isa_ok( $box, 'Fritz::Box' );
is( $box->upnp_url,    'U1', 'Fritz::Box->upnp_url'    );
is( $box->trdesc_path, 'T2', 'Fritz::Box->trdesc_path' );
is( $box->username,    'U3', 'Fritz::Box->username'    );
is( $box->password,    'P4', 'Fritz::Box->password'    );

# discover without Fritz!Box present
$box = new_ok( 'Fritz::Box' );
my $device = $box->discover();
isa_ok( $device, 'Fritz::Error' , 'get Fritz::Error because discovery failed' );

# discover FritzBox
$box = new_ok( 'Fritz::Box' );
$box->_ua->map('http://fritz.box:49000/tr64desc.xml', get_fake_device_response());
isa_ok( $box->discover(), 'Fritz::Device' , 'get Fritz::Device on mocked connect' );

# discover at non-standard URL FritzBox
$box = new_ok( 'Fritz::Box',
	       [ upnp_url    => 'http://example.org:123',
	         trdesc_path => '/tr64'
	       ]
    );
$box->_ua->map('http://example.org:123/tr64', get_fake_device_response());
isa_ok( $box->discover(), 'Fritz::Device' , 'get Fritz::Device on mocked connect with nonstandard URL' );


### internal tests

# _sslopts
$box = new_ok( 'Fritz::Box' );
is_deeply( [ sort keys { @{$box->_sslopts} } ], [ sort $box->_ua->ssl_opts ], 'SSL option keys' );

# dump() #TODO


### helper methods

# prepare a fake device structure
sub get_fake_device_response
{
    local $/ = undef;
    open(my $fh, '<', 't/fake_tr64desc.xml') or die $!;
    my $xml = <$fh>;
    close $fh or die $!;

    my $result = HTTP::Response->new( 200 );
    $result->content( $xml );
    return $result;
}
