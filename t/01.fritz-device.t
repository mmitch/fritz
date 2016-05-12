#!perl
use Test::More tests => 47;
use warnings;
use strict;

use Fritz::Box;

BEGIN { use_ok('Fritz::Device') };

# public methods

subtest 'check fritz getter' => sub {
    # given
    my $fritz = Fritz::Box->new();
    my $device = new_ok( 'Fritz::Device', [ fritz => $fritz, xmltree => undef ] );

    # when
    my $result = $device->fritz;

    # then
    is( $result, $fritz, 'get fritz' );
};

subtest 'check xmltree getter' => sub {
    # given
    my $xmltree = [ some => 'thing' ];
    my $device = new_ok( 'Fritz::Device', [ fritz => undef, xmltree => $xmltree ] );

    # when
    my $result = $device->xmltree;

    # then
    is( $result, $xmltree, 'get xmltree' );
};

subtest 'check service_list getter and converter' => sub {
    # given
    my $fritz = Fritz::Box->new();
    my $xmltree = {
	'serviceList' => [
	    { 'service' => [
		  'FAKE_SERVICE_0',
		  'FAKE_SERVICE_1'
		  ]
	    }
	    ]
    };
    my $device = new_ok( 'Fritz::Device', [ fritz => $fritz, xmltree => $xmltree ] );

    # when
    my $result = $device->service_list;

    # then
    is( ref $device->service_list, 'ARRAY', 'service_list yields arrayref'  );
    my @service_list = @{$device->service_list};
    is( scalar @service_list, 2, 'service_list length' );
    foreach my $i ( 0, 1 ) {
	my $service = $service_list[$i];
	isa_ok( $service, 'Fritz::Service', "service_list[$i] class" );
	is( $service->fritz, $fritz, "service_list[$i]->fritz" );
	is( $service->xmltree, "FAKE_SERVICE_$i", "service_list[$i]->xmltree" );
    }

    is( scalar @{$device->device_list}, 0, 'device_list is empty' );
};


# private methods

# new() with named parameters, xmltree with devices/services
my $device = new_ok( 'Fritz::Device', [ fritz => 'fake', xmltree => get_xmltree_tree() ] );
is( $device->error, '', 'get Fritz::Device instance');
isa_ok( $device, 'Fritz::Device' );

is( $device->fritz, 'fake', 'Fritz::Device->fritz' );

is( ref $device->device_list, 'ARRAY', 'Fritz::Device->device_list type'  );
my @device_list = @{$device->device_list};
is( scalar @device_list, 2, 'Fritz::Device->device_list count' );
isa_ok( $device_list[0], 'Fritz::Device', 'Fritz::Device->device_list[0]' );
isa_ok( $device_list[1], 'Fritz::Device', 'Fritz::Device->device_list[1]' );

is( ref $device->attributes, 'HASH', 'Fritz::Device->attributes type'  );
for my $key (keys %{get_xmltree_device()}) {
    next if $key =~ /^fake/;
    ok( ! exists $device->attributes->{$key}, "Fritz::Device->attributes->{$key} does not exist" );
}

# new() with named parameters, xmltree with information
my $xmltree = get_xmltree_device();
$device = new_ok( 'Fritz::Device', [ fritz => 'fake', xmltree => $xmltree ] );
is( $device->error, '', 'get Fritz::Device instance');
isa_ok( $device, 'Fritz::Device' );

is( $device->fritz, 'fake', 'Fritz::Device->fritz' );

is( ref $device->service_list, 'ARRAY', 'Fritz::Device->service_list type'  );
my @service_list = @{$device->service_list};
is( scalar @service_list, 0, 'Fritz::Device->service_list count' );

is( ref $device->device_list, 'ARRAY', 'Fritz::Device->device_list type'  );
@device_list = @{$device->device_list};
is( scalar @device_list, 0, 'Fritz::Device->device_list count' );

is( ref $device->attributes, 'HASH', 'Fritz::Device->attributes type'  );
for my $key (keys %{$xmltree}) {
    next if $key =~ /^fake/;
    is( $device->attributes->{$key}, $xmltree->{$key}->[0], "Fritz::Device->attributes->{$key}" );
}
for my $key (keys %{$xmltree}) {
    next unless $key =~ /^fake/;
    ok( ! exists $device->attributes->{$key}, "Fritz::Device->attributes->{$key} does not exist" );
}


# helper methods

sub get_xmltree_tree()
{
    return {
	'serviceList' => [
	    { 'service' => [
		  'FAKE_SERVICE_1',
		  'FAKE_SERVICE_2'
		  ]
	    }
	    ],
	'deviceList' => [
	    { 'device' => [
		  'FAKE_SUBDEVICE_1',
		  'FAKE_SUBDEVICE_2'
		  ]
	    }
	    ],
    }
}

sub get_xmltree_device()
{
    return {
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
    }
}


