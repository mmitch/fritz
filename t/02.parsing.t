#!perl
use Test::More tests => 77;
use warnings;
use strict;

use Cwd qw(abs_path);

BEGIN { use_ok('Fritz::Box') };

# looks for a file in different paths
# and returns the filename with absolute path
sub search_for_file {
    my $file = shift;
    my $found;
    for my $path( 't/', '' ) {
	my $check = $path.$file;
	if (-r $check) {
	    $found = abs_path($check);
	    last;
	}
    }
    return $found;
}

# locate faked XML files
my $trdesc_file = search_for_file('fake_tr64desc.xml');
isnt( $trdesc_file, undef, 'find fake TR64 XML file');
my $scpd_file = search_for_file('fakeSCPD.xml');
isnt( $scpd_file, undef, 'find fake SCPD XML file');

# startup + device descovery
note('=== startup + device descovery');
my $box = new_ok( 'Fritz::Box', [
		      upnp_url => 'file://',
		      trdesc_path => $trdesc_file
		  ] );
is( $box->error, '', 'get Fritz::Box' );

my $device = $box->discover();
is( $device->error, '', 'get Fritz::Device' );

# check root device
note('=== check root device');
my %root_device_attributes = (
    deviceType => 'FakeDevice:1',
    friendlyName => 'UnitTest Unit',
    manufacturer => 'fake',
    manufacturerURL => 'http://example.org/1',
    modelDescription => 'fake model description',
    modelName => 'fake model name',
    modelNumber => 'fake model number',
    modelURL => 'http://example.org/2',
    UDN => 'uuid:1',
    presentationURL => 'http://localhost',
);
for my $attribute (keys %root_device_attributes) {
    is( $device->attributes->{$attribute}, $root_device_attributes{$attribute}, "check $attribute" );
}

my @services = @{$device->service_list};
is( scalar @services, 1, 'service count');
isa_ok( $services[0], 'Fritz::Service', 'service class' );
is ($services[0]->serviceId, 'fakeService1', 'service id' );

my @devices = @{$device->device_list};
is( scalar @devices, 1, 'device count');
isa_ok( $devices[0], 'Fritz::Device', 'device class' );
is ($devices[0]->attributes->{deviceType}, 'FakeSubDevice:1', 'device type' );

# check search methods
note('=== check search methods');
my $service = $device->get_service('GNARGLGHAST');
isa_ok( $service, 'Fritz::Error', 'not found' );

$service = $device->get_service('FakeService:1');
isa_ok( $service, 'Fritz::Service', 'service class' );
is ($service->serviceId, 'fakeService1', 'service id' );


$service = $device->find_service('GNARGLGHAST');
isa_ok( $service, 'Fritz::Error', 'not found' );

$service = $device->find_service('Service');
isa_ok( $service, 'Fritz::Service', 'service class' );
is ($service->serviceId, 'fakeService1', 'service id' );


my $data = $device->find_service_names('GNARGLGHAST');
isa_ok( $data, 'Fritz::Data', 'service list' );
@services = @{$data->data};
is( scalar @services, 0, 'service count');

$data = $device->find_service_names('Service');
isa_ok( $data, 'Fritz::Data', 'service list' );
@services = @{$data->data};
is( scalar @services, 2, 'service count');
isa_ok( $services[0], 'Fritz::Service', 'service class #1' );
isa_ok( $services[1], 'Fritz::Service', 'service class #2' );
is ($services[0]->serviceId, 'fakeService1', 'service id #1' );
is ($services[1]->serviceId, 'fakeService2', 'service id #2' );


my $subdevice = $device->find_device('GNARGLGHAST');
isa_ok( $subdevice, 'Fritz::Error', 'not found' );

$subdevice = $device->find_device('FakeSubDevice:1');
isa_ok( $subdevice, 'Fritz::Device', 'device class' );
is ($subdevice->attributes->{deviceType}, 'FakeSubDevice:1', 'device type' );

# check subdevice
note('=== check subdevice');
my %subdevice_attributes = (
    deviceType => 'FakeSubDevice:1',
    friendlyName => 'UnitTest Unit Subdevice',
    manufacturer => 'fake',
    manufacturerURL => 'http://example.org/3',
    modelDescription => 'fake model description - subdevice',
    modelName => 'fake model name - subdevice',
    modelNumber => 'fake model number - subdevice',
    modelURL => 'http://example.org/4',
    UDN => 'uuid:2',
    presentationURL => undef,
);
for my $attribute (keys %subdevice_attributes) {
    if (defined $subdevice_attributes{$attribute}) {
	is( $subdevice->attributes->{$attribute}, $subdevice_attributes{$attribute}, "check $attribute" );
    } else {
	ok( ! exists $subdevice->attributes->{$attribute}, "check $attribute" );
    }
}

@services = @{$subdevice->service_list};
is( scalar @services, 1, 'service count');
isa_ok( $services[0], 'Fritz::Service', 'service class' );
is ($services[0]->serviceId, 'fakeService2', 'service id' );

@devices = @{$subdevice->device_list};
is( scalar @devices, 0, 'device count');

# check service on root device
note('=== check service on root device');
$service = $device->get_service('FakeService:1');
my %service_vars = (
    serviceType => 'FakeService:1',
    serviceId => 'fakeService1',
    controlURL => '/upnp/control/deviceinfo',
    eventSubURL => '/upnp/control/deviceinfo',
    SCPDURL => 'fakeSCPD.xml',
);
for my $var (keys %service_vars) {
    is( $service->$var, $service_vars{$var}, "check $var" );
}

$service->_set_SCPDURL($scpd_file); # overwrite SCPDURL with computed location of test file

my %actions = %{$service->action_hash};
is( scalar keys %actions, 1, 'action count' );
my $action = (values %actions)[0];
isa_ok( $action, 'Fritz::Action', 'action type' );
is( $action->name, 'SomeService', 'action name' );
my @args = @{$action->args_in};
is( scalar @args, 1, 'args_in count' );
is( $args[0], 'InputArgument', 'args_in[0] name' );
@args = @{$action->args_out};
is( scalar @args, 1, 'args_out count' );
is( $args[0], 'OutputArgument', 'args_out[0] name' );


# check service on subdevice
note('=== check service on subdevice');
$service = $subdevice->get_service('FakeService:1');
%service_vars = (
    serviceType => 'FakeService:1',
    serviceId => 'fakeService2',
    controlURL => '/upnp/control/deviceinfo',
    eventSubURL => '/upnp/control/deviceinfo',
    SCPDURL => 'fakeSCPD.xml',
);
for my $var (keys %service_vars) {
    is( $service->$var, $service_vars{$var}, "check $var" );
}

$service->_set_SCPDURL($scpd_file); # overwrite SCPDURL with computed location of test file

%actions = %{$service->action_hash};
is( scalar keys %actions, 1, 'action count' );
$action = (values %actions)[0];
isa_ok( $action, 'Fritz::Action', 'action type' );
is( $action->name, 'SomeService', 'action name' );
@args = @{$action->args_in};
is( scalar @args, 1, 'args_in count' );
is( $args[0], 'InputArgument', 'args_in[0] name' );
@args = @{$action->args_out};
is( scalar @args, 1, 'args_out count' );
is( $args[0], 'OutputArgument', 'args_out[0] name' );
