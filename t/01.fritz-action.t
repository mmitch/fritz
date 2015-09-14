#!perl
use Test::More tests => 15;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Action') };

# setup data
my $xmltree = {
    'name' => [ 'NAME' ],
    'argumentList' => [ { 'argument' => [
			      { name      => [ 'IN1' ],
				direction => [ 'in' ]
			      },
			      { name      => [ 'IN2' ],
				direction => [ 'in' ]
			      },
			      { name      => [ 'OUT' ],
				direction => [ 'out' ]
			      },
			      ]
			}
	]
};

# new() with named parameters
my $action = new_ok( 'Fritz::Action', [ xmltree => $xmltree ] );
is( $action->error, '', 'get Fritz::Action instance');
isa_ok( $action, 'Fritz::Action' );
is( $action->name,          'NAME', 'Fritz::Action->name'    );
is( $action->args_in->[0],  'IN1',  'Fritz::Action->args_in->[0]' );
is( $action->args_in->[1],  'IN2',  'Fritz::Action->args_in->[1]' );
is( $action->args_out->[0], 'OUT',  'Fritz::Action->args_out->[0]' );

# new() with unnamed parameter
$action = new_ok( 'Fritz::Action', [ $xmltree ] );
is( $action->error, '', 'get Fritz::Action instance');
isa_ok( $action, 'Fritz::Action' );
is( $action->name,          'NAME', 'Fritz::Action->name'    );
is( $action->args_in->[0],  'IN1',  'Fritz::Action->args_in->[0]' );
is( $action->args_in->[1],  'IN2',  'Fritz::Action->args_in->[1]' );
is( $action->args_out->[0], 'OUT',  'Fritz::Action->args_out->[0]' );
