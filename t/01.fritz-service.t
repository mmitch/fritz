#!perl
use Test::More tests => 18;
use warnings;
use strict;

use Test::Mock::LWP::Dispatch;
use Fritz::Box;

BEGIN { use_ok('Fritz::Service') };

### public tests

subtest 'check fritz getter, set via new()' => sub {
    # given
    my $fritz = Fritz::Box->new();
    my $service = new_ok( 'Fritz::Service', [ fritz => $fritz, xmltree => undef ] );

    # when
    my $result = $service->fritz;

    # then
    is( $result, $fritz, 'get fritz' );
};

subtest 'check xmltree getter, set via new()' => sub {
    # given
    my $xmltree = [ some => 'thing' ];
    my $service = new_ok( 'Fritz::Service', [ fritz => undef, xmltree => $xmltree ] );

    # when
    my $result = $service->xmltree;

    # then
    is( $result, $xmltree, 'get xmltree' );
};

subtest 'check for scpd error after HTTP error' => sub {
    # given
    my $xmltree = { SCPDURL => [ '' ] };
    my $fritz = new_ok( 'Fritz::Box' );
    my $service = new_ok( 'Fritz::Service', [ fritz => $fritz, xmltree => $xmltree ] );

    # when
    my $result = $service->scpd;

    # then
    isa_ok( $result, 'Fritz::Error', 'SCPD conversion result' );
};

subtest 'check scpd after successful HTTP GET' => sub {
    # given
    my $service = create_service_with_scpd_data();

    # when
    my $result = $service->scpd;

    # then
    isa_ok( $result, 'Fritz::Data', 'SCPD conversion result' );
    isa_ok( $result->data, 'HASH', 'SCPD result data' );
};

subtest 'check action hash' => sub {
    # given
    my $service = create_service_with_scpd_data();
    my $service_name = 'SomeService';

    # when
    my $result = $service->action_hash;

    # then
    isa_ok( $result, 'HASH', 'action_hash result' );
    ok( exists $result->{$service_name}, 'action exists' );
    isa_ok( $result->{$service_name}, 'Fritz::Action', 'action' );
};

subtest 'check attribute getters' => sub {
    # given
    my $xmltree = {
	'serviceType' => [ 'SRV_TYPE' ],
	'serviceId' => [ 'SRV_ID' ],
	'controlURL' => [ 'CTRL_URL' ],
	'eventSubURL' => [ 'EV_SUB_URL' ],
	'SCPDURL' => [ 'SCPD_URL' ],
    };
    my $service = new_ok( 'Fritz::Service', [ fritz => undef, xmltree => $xmltree ] );

    foreach my $key (keys %{$xmltree}) {
	# when
	my $result = $service->$key;

	# then
	is( $result, $xmltree->{$key}->[0], "$key content" );
    }
};

subtest 'check service call' => sub {
    plan skip_all => 'does not work yet';
    # given
    my $service = create_service_with_scpd_data();
    my $service_name = 'SomeService';
    my @arguments = ('InputArgument' => 'foo');
    $mock_ua->map($service->fritz->upnp_url.$service->controlURL, get_fake_soap_response());

    # when
    my $result = $service->call($service_name, @arguments);

    # then
    warn $result->error;
    isa_ok( $result, 'Fritz::Data', 'response data' );
};

# prepare XML tree data

my $xmltree = {
    'serviceType' => [ 'S_TYPE' ],
    'serviceId' => [ 'S_ID' ],
    'controlURL' => [ 'C_URL' ],
    'eventSubURL' => [ 'ES_URL' ],
    'SCPDURL' => [ 'SCPD_URL' ],
    'fake_key' => [ 'does_not_exist' ]
};


# new() with named parameters
my $service = new_ok( 'Fritz::Service', [ fritz => 'fake', xmltree => $xmltree ] );
is( $service->error, '', 'get Fritz::Service instance');
isa_ok( $service, 'Fritz::Service' );

is( $service->fritz, 'fake', 'Fritz::Service->fritz' );

for my $key (keys %{$xmltree}) {
    next if $key =~ /^fake/;
    is( $service->$key, $xmltree->{$key}->[0], "Fritz::Service->$key" );
}
for my $key (keys %{$xmltree}) {
    next unless $key =~ /^fake/;
    ok( ! exists $service->{$key}, "Fritz::Service->$key does not exist" );
}

### helper methods

sub get_fake_soap_response
{
    my $result = HTTP::Response->new( 200 );
    $result->content( get_soap_xml() );
    return $result;
}

sub get_fake_scpd_response
{
    my $result = HTTP::Response->new( 200 );
    $result->content( get_scpd_xml() );
    return $result;
}

sub create_service_with_scpd_data
{
    my $fritz = new_ok( 'Fritz::Box' );
    my $xmltree = {
	SCPDURL => [ '/SCPD' ],
	controlURL => [ '/control' ],
    };
    my $service = new_ok( 'Fritz::Service', [ fritz => $fritz, xmltree => $xmltree ] );
    $fritz->_ua->map($fritz->upnp_url.$service->SCPDURL, get_fake_scpd_response());
    return $service;
}

sub get_scpd_xml {
    my $SCPD_XML = <<EOF;
<?xml version="1.0"?>
<scpd xmlns="urn:dslforum-org:service-1-0">
  <actionList>
    <action>
      <name>SomeService</name>
      <argumentList>
	<argument>
	  <name>OutputArgument</name>
	  <direction>out</direction>
	  <relatedStateVariable>Argument</relatedStateVariable>
	</argument>
	<argument>
	  <name>InputArgument</name>
	  <direction>in</direction>
	  <relatedStateVariable>Argument</relatedStateVariable>
	</argument>
      </argumentList>
    </action>
  </actionList>
  <serviceStateTable>
    <stateVariable sendEvents="yes">
      <name>Argument</name>
      <dataType>string</dataType>
      <defaultValue>0815</defaultValue>
    </stateVariable>
  </serviceStateTable>
</scpd>
EOF
;
}

sub get_soap_xml {
    my $SOAP_XML = <<EOF;
<Envelope>
<Body>
<SomeServiceResponse>
<OutputArgument>foo</OutputArgument>
</SomeServiceResponse>
</Body>
</Envelope>
EOF
;
}
