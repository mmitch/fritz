#!perl
use Test::More tests => 44;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Device') };

# prepare XML tree data

my $xmltree_1 = {
        'serviceList' => [ { 'service' => [
	    'FAKE_SERVICE_1',
	    'FAKE_SERVICE_2'
	] } ],
	
	'deviceList' => [ { 'device' => [
	    'FAKE_SUBDEVICE_1',
	    'FAKE_SUBDEVICE_2'
	] } ],
};

my $xmltree_2 = {
    'deviceType' => [ 'DEV_TYPE' ],
    'friendlyName' => [ 'F_NAME' ],
    'manufacturer' => [ 'MAN' ],
    'manufacturerURL' => [ 'MAN_URL' ],
    'modelDescription' => [ 'MOD_DESC' ],
    'modelName' => [ 'MOD_NAME' ],
    'modelNumber' => [ 'MOD_NUMBER' ],
    'modelURL' => [ 'MOD_URL' ],
    'UDN' => [ 'UDN' ],
    'presentationURL' => [ 'P_URL' ],
    'fake_key' => [ 'does_not_exist' ]
};


# new() with named parameters, xmltree with devices/services
my $device = new_ok( 'Fritz::Device', [ fritz => 'fake', xmltree => $xmltree_1 ] );
is( $device->error, '', 'get Fritz::Device instance');
isa_ok( $device, 'Fritz::Device' );

is( $device->fritz, 'fake', 'Fritz::Device->fritz' );

is( ref $device->service_list, 'ARRAY', 'Fritz::Device->service_list type'  );
my @service_list = @{$device->service_list};
is( scalar @service_list, 2, 'Fritz::Device->service_list count' );
isa_ok( $service_list[0], 'Fritz::Service', 'Fritz::Device->service_list[0]' );
isa_ok( $service_list[1], 'Fritz::Service', 'Fritz::Device->service_list[1]' );

is( ref $device->device_list, 'ARRAY', 'Fritz::Device->device_list type'  );
my @device_list = @{$device->device_list};
is( scalar @device_list, 2, 'Fritz::Device->device_list count' );
isa_ok( $device_list[0], 'Fritz::Device', 'Fritz::Device->device_list[0]' );
isa_ok( $device_list[1], 'Fritz::Device', 'Fritz::Device->device_list[1]' );

is( ref $device->attributes, 'HASH', 'Fritz::Device->attributes type'  );
for my $key (keys %{$xmltree_2}) {
    next if $key =~ /^fake/;
    ok( ! exists $device->attributes->{$key}, "Fritz::Device->attributes->{$key} does not exist" );
}

# new() with named parameters, xmltree with information
$device = new_ok( 'Fritz::Device', [ fritz => 'fake', xmltree => $xmltree_2 ] );
is( $device->error, '', 'get Fritz::Device instance');
isa_ok( $device, 'Fritz::Device' );

is( $device->fritz, 'fake', 'Fritz::Device->fritz' );

is( ref $device->service_list, 'ARRAY', 'Fritz::Device->service_list type'  );
@service_list = @{$device->service_list};
is( scalar @service_list, 0, 'Fritz::Device->service_list count' );

is( ref $device->device_list, 'ARRAY', 'Fritz::Device->device_list type'  );
@device_list = @{$device->device_list};
is( scalar @device_list, 0, 'Fritz::Device->device_list count' );

is( ref $device->attributes, 'HASH', 'Fritz::Device->attributes type'  );
for my $key (keys %{$xmltree_2}) {
    next if $key =~ /^fake/;
    is( $device->attributes->{$key}, $xmltree_2->{$key}->[0], "Fritz::Device->attributes->{$key}" );
}
for my $key (keys %{$xmltree_2}) {
    next unless $key =~ /^fake/;
    ok( ! exists $device->attributes->{$key}, "Fritz::Device->attributes->{$key} does not exist" );
}

