#!perl
use Test::More;
use warnings;
use strict;

use Fritz::Box;

# check if a Fritz!Box is available - otherwise skip

if (my $error = Fritz::Box->new()->discover->error) {
    plan skip_all => 'no device found, further tests skipped: ' . $error;
} else {
    plan tests => 21;
}

# get normal port
my $fritz = new_ok( 'Fritz::Box' );
is( $fritz->error, '', 'get Fritz::Box instance');
isa_ok( $fritz, 'Fritz::Box' );

my $device = $fritz->discover();
is( $device->error, '', 'get Fritz::Device instance');
isa_ok( $device, 'Fritz::Device' );

my $service = $device->find_service('DeviceInfo:1');
is( $service->error, '', 'get DeviceInfo service');
isa_ok( $service, 'Fritz::Service' );

my $response = $service->call('GetSecurityPort');
is( $response->error, '', 'call CatSecurityPort');
isa_ok( $response, 'Fritz::Data' );

my $port = $response->data->{NewSecurityPort};
ok( $port > 0, 'get port number');


# now use the port to call the same service via SSL
my $upnp_url = $fritz->upnp_url;
$upnp_url =~ s/http:/https:/;
$upnp_url =~ s/:49000/:$port/;

my $fritz_ssl = new_ok( 'Fritz::Box' => [ upnp_url => $upnp_url ] );
is ($fritz_ssl->error, '', 'get Fritz::Box instance for SSL');
isa_ok( $fritz_ssl, 'Fritz::Box' );

my $device_ssl = $fritz_ssl->discover();
is( $device_ssl->error, '', 'get Fritz::Device');
isa_ok( $device_ssl, 'Fritz::Device' );

my $service_ssl = $device_ssl->find_service('DeviceInfo:1');
is( $service_ssl->error, '', 'get DeviceInfo service via SSL');
isa_ok( $service_ssl, 'Fritz::Service' );

my $response_ssl = $service_ssl->call('GetSecurityPort');
is( $response_ssl->error, '', 'call CatSecurityPort via SSL');
isa_ok( $response, 'Fritz::Data' );

my $port_ssl = $response_ssl->data->{NewSecurityPort};
ok( $port_ssl > 0, 'get port number');

is( $port, $port_ssl, 'port number comparison');
