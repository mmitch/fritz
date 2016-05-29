#!perl
use Test::More;
use warnings;
use strict;

use Fritz::Box;

# check if a live test is wanted - otherwise skip
if (exists $ENV{AUTHOR_TEST} and $ENV{AUTHOR_TEST} eq 'fritz') {
    plan tests => 10;
} else {
    plan skip_all => 'needs a real Fritz!Box (set AUTHOR_TEST=fritz to enable)';
}

# connect on normal http port and call a service
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
cmp_ok( $port,  '>', 0, 'get port number');
