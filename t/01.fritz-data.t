#!perl
use Test::More tests => 9;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Data') };

# new() with named parameters
my $data = new_ok( 'Fritz::Data', [ data => 'foo' ] );
is( $data->error, '', 'get Fritz::Data instance');
isa_ok( $data, 'Fritz::Data' );
is( $data->data, 'foo', 'Fritz::Data->name');

# new() with unnamed parameter
$data = new_ok( 'Fritz::Data', [ 'FOO' ] );
is( $data->error, '', 'get Fritz::Data instance');
isa_ok( $data, 'Fritz::Data' );
is( $data->data, 'FOO', 'Fritz::Data->name');
