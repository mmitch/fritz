#!perl
use Test::More tests => 3;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Error') };


### public tests

subtest 'check new()' => sub {
    my $error = new_ok( 'Fritz::Error', [ error => 'SOME_ERROR' ] );
    isa_ok( $error, 'Fritz::Error' );
    is( $error->error, 'SOME_ERROR', 'Fritz::Error->error' );
};
    
subtest 'check dump' => sub {
    my $error = new_ok( 'Fritz::Error', [ 'SOME_OTHER_ERROR' ] );
    my $dump = $error->dump();
    like( $dump, qr/Fritz::Error/, 'class name is dumped' );
    like( $dump, qr/SOME_OTHER_ERROR/, 'errortext is dumped' );
};
