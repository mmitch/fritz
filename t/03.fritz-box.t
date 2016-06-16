#!perl
use Test::More tests => 8;
use warnings;
use strict;

use Test::Mock::LWP::Dispatch;
use HTTP::Response;

BEGIN { use_ok('Net::Fritz::Box') };


### public tests

subtest 'check new()' => sub {
    my $box = new_ok( 'Net::Fritz::Box' );
    is( $box->error, '', 'get Net::Fritz::Box instance');
    isa_ok( $box, 'Net::Fritz::Box' );
    is( $box->upnp_url,    'http://fritz.box:49000', 'Net::Fritz::Box->upnp_url'    );
    is( $box->trdesc_path, '/tr64desc.xml',          'Net::Fritz::Box->trdesc_path' );
    is( $box->username,    undef,                    'Net::Fritz::Box->username'    );
    is( $box->password,    undef,                    'Net::Fritz::Box->password'    );
};

subtest 'check new() with parameters' => sub {
    my $box = new_ok( 'Net::Fritz::Box',
		      [ upnp_url    => 'U1',
			trdesc_path => 'T2',
			username    => 'U3',
			password    => 'P4'
		      ]
	);
    is( $box->error, '', 'get Net::Fritz::Box instance');
    isa_ok( $box, 'Net::Fritz::Box' );
    is( $box->upnp_url,    'U1', 'Net::Fritz::Box->upnp_url'    );
    is( $box->trdesc_path, 'T2', 'Net::Fritz::Box->trdesc_path' );
    is( $box->username,    'U3', 'Net::Fritz::Box->username'    );
    is( $box->password,    'P4', 'Net::Fritz::Box->password'    );
};

subtest 'check discover() without Net::Fritz!Box present' => sub {
    my $box = new_ok( 'Net::Fritz::Box' );
    isa_ok( $box->discover(), 'Net::Fritz::Error' , 'failed discovery' );
};

subtest 'check discover() with mocked Net::Fritz!Box' => sub {
    my $box = new_ok( 'Net::Fritz::Box' );
    $box->_ua->map('http://fritz.box:49000/tr64desc.xml', get_fake_device_response());
    isa_ok( $box->discover(), 'Net::Fritz::Device' , 'mocked discovery' );
};

subtest 'check discover() with mocked Net::Fritz!Box at non-standard URL' => sub {
    my $box = new_ok( 'Net::Fritz::Box',
		   [ upnp_url    => 'http://example.org:123',
		     trdesc_path => '/tr64'
		   ]
	);
    $box->_ua->map('http://example.org:123/tr64', get_fake_device_response());
    isa_ok( $box->discover(), 'Net::Fritz::Device' , 'mocked discovery' );
};


### internal tests

subtest 'check _sslopts' => sub {
    my $box = new_ok( 'Net::Fritz::Box' );
    my %box_sslopts = @{$box->_sslopts};
    is_deeply( [ sort keys %box_sslopts ], [ sort $box->_ua->ssl_opts ], 'SSL option keys' );
};

subtest 'check dump()' => sub {
    my $box = new_ok( 'Net::Fritz::Box' );

    my $dump = $box->dump('xxx');
    foreach my $line (split /\n/, $dump) {
	like( $line, qr/^xxx/, 'line starts with given indent' );
    }

    $dump = $box->dump();
    foreach my $line (split /\n/, $dump) {
	like( $line, qr/^(Net::Fritz|  )/, 'line starts as expected' );
    }

    like( $dump, qr/Net::Fritz::Box/, 'class name is dumped' );

    my $upnp_url = $box->upnp_url;
    like( $dump, qr/$upnp_url/, 'upnp_url is dumped' );
    my $trdesc_path = $box->trdesc_path;
    like( $dump, qr/$trdesc_path/, 'trdesc_path is dumped' );
};


### helper methods

sub get_fake_device_response
{
    my $xml = get_tr64desc_xml();

    my $result = HTTP::Response->new( 200 );
    $result->content( $xml );
    return $result;
}

sub get_tr64desc_xml
{
    my $tr64_desc_xml = <<EOF;
<?xml version="1.0"?>
<root xmlns="urn:dslforum-org:device-1-0">
  <device>
    <deviceType>FakeDevice:1</deviceType>
    <friendlyName>UnitTest Unit</friendlyName>
    <manufacturer>fake</manufacturer>
    <manufacturerURL>http://example.org/1</manufacturerURL>
    <modelDescription>fake model description</modelDescription>
    <modelName>fake model name</modelName>
    <modelNumber>fake model number</modelNumber>
    <modelURL>http://example.org/2</modelURL>
    <UDN>uuid:1</UDN>
    <serviceList>
      <service>
	<serviceType>FakeService:1</serviceType>
	<serviceId>fakeService1</serviceId>
	<controlURL>/upnp/control/deviceinfo</controlURL>
	<eventSubURL>/upnp/control/deviceinfo</eventSubURL>
	<SCPDURL>fakeSCPD.xml</SCPDURL>
      </service>
    </serviceList>
    <deviceList>
      <device>
	<deviceType>FakeSubDevice:1</deviceType>
	<friendlyName>UnitTest Unit Subdevice</friendlyName>
	<manufacturer>fake</manufacturer>
	<manufacturerURL>http://example.org/3</manufacturerURL>
	<modelDescription>fake model description - subdevice</modelDescription>
	<modelName>fake model name - subdevice</modelName>
	<modelNumber>fake model number - subdevice</modelNumber>
	<modelURL>http://example.org/4</modelURL>
	<UDN>uuid:2</UDN>
	<serviceList>
	  <service>
	    <serviceType>FakeService:1</serviceType>
	    <serviceId>fakeService2</serviceId>
	    <controlURL>/upnp/control/deviceinfo</controlURL>
	    <eventSubURL>/upnp/control/deviceinfo</eventSubURL>
	    <SCPDURL>fakeSCPD.xml</SCPDURL>
	  </service>
	</serviceList>
      </device>
    </deviceList>
    <presentationURL>http://localhost</presentationURL>
  </device>
</root>
EOF
    ;
}
