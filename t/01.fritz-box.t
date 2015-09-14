#!perl
use Test::More tests => 15;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Box') };

# new()
my $box = new_ok( 'Fritz::Box' );
is( $box->error, '', 'get Fritz::Box instance');
isa_ok( $box, 'Fritz::Box' );
is( $box->upnp_url,    'http://fritz.box:49000', 'Fritz::Box->upnp_url'    );
is( $box->trdesc_path, '/tr64desc.xml',          'Fritz::Box->trdesc_path' );
is( $box->username,    undef,                    'Fritz::Box->username'    );
is( $box->password,    undef,                    'Fritz::Box->password'    );

# new() with parameters
$box = new_ok( 'Fritz::Box',
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
