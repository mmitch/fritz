#!perl
use Test::More;
use warnings;
use strict;

BEGIN { use_ok ('Fritz::Box'); }

# get normal port
my $fritz = new_ok( 'Fritz::Box' );
isa_ok( $fritz, 'Fritz::Box' );
is( $fritz->error, 0, 'get Fritz::Box instance');

my $device = $fritz->discover();
if ($device->error) {
    plan skip_all => 'no device found, further tests skipped: ' . $device->error;
}
else {
    plan tests => 20;
}
isa_ok( $device, 'Fritz::Device' );

my $service = $device->find_service('DeviceInfo:1');
is( $service->error, 0, 'get DeviceInfo service');
isa_ok( $service, 'Fritz::Service' );

my $response = $service->call('GetSecurityPort');
is( $response->error, 0, 'call CatSecurityPort');
isa_ok( $response, 'Fritz::Data' );

my $port = $response->data->{NewSecurityPort};
ok( $port > 0, 'get port number');


# now use the port to call the same service via SSL
my $upnp_url = $fritz->upnp_url;
$upnp_url =~ s/http:/https:/;
$upnp_url =~ s/:49000/:$port/;

my $fritz_ssl = new_ok( Fritz::Box->new( upnp_url => $upnp_url ) );
is ($fritz_ssl->error, 0, 'get Fritz::Box instance for SSL');

my $device_ssl = $fritz_ssl->discover();
is( $device_ssl->error, 0, 'get Fritz::Device');
isa_ok( $device_ssl, 'Fritz::Device' );

my $service_ssl = $device_ssl->find_service('DeviceInfo:1');
is( $service_ssl->error, 0, 'get DeviceInfo service via SSL');
isa_ok( $service_ssl, 'Fritz::Service' );

my $response_ssl = $service_ssl->call('GetSecurityPort');
is( $response_ssl->error, 0, 'call CatSecurityPort via SSL');
isa_ok( $response, 'Fritz::Data' );

my $port_ssl = $response_ssl->data->{NewSecurityPort};
ok( $port_ssl > 0, 'get port number');

is( $port, $port_ssl, 'port number comparison');
