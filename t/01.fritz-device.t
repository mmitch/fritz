#!perl
use Test::More tests => 8;
use warnings;
use strict;

use Fritz::Box;

BEGIN { use_ok('Fritz::Device') };

### public tests

subtest 'check fritz getter, set via new()' => sub {
    # given
    my $fritz = Fritz::Box->new();
    my $device = new_ok( 'Fritz::Device', [ fritz => $fritz, xmltree => undef ] );

    # when
    my $result = $device->fritz;

    # then
    is( $result, $fritz, 'get fritz' );
};

subtest 'check xmltree getter, set via new()' => sub {
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

subtest 'check device_list getter and converter' => sub {
    # given
    my $fritz = Fritz::Box->new();
    my $xmltree = {
	'deviceList' => [
	    { 'device' => [
		  'FAKE_SUBDEVICE_0',
		  'FAKE_SUBDEVICE_1'
		  ]
	    }
	    ]
    };
    my $device = new_ok( 'Fritz::Device', [ fritz => $fritz, xmltree => $xmltree ] );

    # when
    my $result = $device->device_list;

    # then
    is( ref $device->device_list, 'ARRAY', 'device_list yields arrayref'  );
    my @device_list = @{$device->device_list};
    is( scalar @device_list, 2, 'device_list length' );
    foreach my $i ( 0, 1 ) {
	my $device = $device_list[$i];
	isa_ok( $device, 'Fritz::Device', "device_list[$i] class" );
	is( $device->fritz, $fritz, "device_list[$i]->fritz" );
	is( $device->xmltree, "FAKE_SUBDEVICE_$i", "device_list[$i]->xmltree" );
    }

    is( scalar @{$device->service_list}, 0, 'service_list is empty' );
};

subtest 'check attribute getters' => sub {
    # given
    my $xmltree = {
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
    my $device = new_ok( 'Fritz::Device', [ fritz => undef, xmltree => $xmltree ] );

    foreach my $key (keys %{$xmltree}) {
	# when
	my $result = $device->attributes->{$key};

	if ($key =~ /^fake/) {
	    is( $result, undef, "attributes->{$key} is undefined" );
	    ok( ! exists $device->attributes->{$key}, "attributes->{$key} does not exist" );
	} else {
	    is( $result, $xmltree->{$key}->[0], "attributes->{$key} content" );
	}    
    }
};

subtest 'check Fritz::IsNoError role' => sub {
    # given

    # when
    my $device = new_ok( 'Fritz::Device' );

    # then
    ok( $device->does('Fritz::IsNoError'), 'does Fritz::IsNoError role' );
};

# TODO: check get_service(name) -> success
# TODO: check get_service(name) -> fail with Fritz::Error

# TODO: check find_service(regexp) -> success
# TODO: check find_service(regexp) -> fail with Fritz::Error

# TODO: check find_service_names(regexp) -> success
# TODO: check find_service_names(regexp) -> fail with Fritz::Error

# TODO: check find_device(regexp) -> success
# TODO: check find_device(regexp) -> fail with Fritz::Error


### internal tests

subtest 'check new()' => sub {
    # given

    # when
    my $device = new_ok( 'Fritz::Device' );

    # then
    isa_ok( $device, 'Fritz::Device' );
};

# TODO: check dump()


### helper methods

