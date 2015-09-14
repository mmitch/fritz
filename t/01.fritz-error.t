#!perl
use Test::More tests => 7;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Error') };

# new() with named parameter
my $error = new_ok( 'Fritz::Error', [ error => 'SOME_ERROR' ] );
isa_ok( $error, 'Fritz::Error' );
is( $error->error, 'SOME_ERROR', 'Fritz::Error->error' );

# new() with unnamed parameter
$error = new_ok( 'Fritz::Error', [ 'SOME_OTHER_ERROR' ] );
isa_ok( $error, 'Fritz::Error' );
is( $error->error, 'SOME_OTHER_ERROR', 'Fritz::Error->error' );
