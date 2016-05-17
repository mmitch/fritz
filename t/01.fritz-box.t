#!perl
use Test::More tests => 8;
use warnings;
use strict;

use Test::Mock::LWP::Dispatch;
use HTTP::Response;

BEGIN { use_ok('Fritz::Box') };

### public tests

subtest 'check new()' => sub {
    my $box = new_ok( 'Fritz::Box' );
    is( $box->error, '', 'get Fritz::Box instance');
    isa_ok( $box, 'Fritz::Box' );
    is( $box->upnp_url,    'http://fritz.box:49000', 'Fritz::Box->upnp_url'    );
    is( $box->trdesc_path, '/tr64desc.xml',          'Fritz::Box->trdesc_path' );
    is( $box->username,    undef,                    'Fritz::Box->username'    );
    is( $box->password,    undef,                    'Fritz::Box->password'    );
};

subtest 'check new() with parameters' => sub {
    my $box = new_ok( 'Fritz::Box',
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
};

subtest 'check discover() without Fritz!Box present' => sub {
    my $box = new_ok( 'Fritz::Box' );
    isa_ok( $box->discover(), 'Fritz::Error' , 'failed discovery' );
};

subtest 'check discover() with mocked Fritz!Box' => sub {
    my $box = new_ok( 'Fritz::Box' );
    $box->_ua->map('http://fritz.box:49000/tr64desc.xml', get_fake_device_response());
    isa_ok( $box->discover(), 'Fritz::Device' , 'mocked discovery' );
};

subtest 'check discover() with mocked Fritz!Box at non-standard URL' => sub {
    my $box = new_ok( 'Fritz::Box',
		   [ upnp_url    => 'http://example.org:123',
		     trdesc_path => '/tr64'
		   ]
	);
    $box->_ua->map('http://example.org:123/tr64', get_fake_device_response());
    isa_ok( $box->discover(), 'Fritz::Device' , 'mocked discovery' );
};


### internal tests

subtest 'check _sslopts' => sub {
    my $box = new_ok( 'Fritz::Box' );
    is_deeply( [ sort keys { @{$box->_sslopts} } ], [ sort $box->_ua->ssl_opts ], 'SSL option keys' );
};

subtest 'check dump()' => sub {
    my $box = new_ok( 'Fritz::Box' );

    my $dump = $box->dump('xxx');
    foreach my $line (split /\n/, $dump) {
	like( $line, qr/^xxx/, 'line starts with given indent' );
    }

    $dump = $box->dump();
    foreach my $line (split /\n/, $dump) {
	like( $line, qr/^(Fritz|  )/, 'line starts as expected' );
    }

    like( $dump, qr/Fritz::Box/, 'class name is dumped' );

    my $upnp_url = $box->upnp_url;
    like( $dump, qr/$upnp_url/, 'upnp_url is dumped' );
    my $trdesc_path = $box->trdesc_path;
    like( $dump, qr/$trdesc_path/, 'trdesc_path is dumped' );
};


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
