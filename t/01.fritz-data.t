#!perl
use Test::More tests => 4;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Data') };


### public tests

subtest 'check new() with named parameters' => sub {
    my $data = new_ok( 'Fritz::Data', [ data => 'foo' ] );
    is( $data->error, '', 'get Fritz::Data instance');
    isa_ok( $data, 'Fritz::Data' );
    is( $data->data, 'foo', 'Fritz::Data->name');
};

subtest 'check get()' => sub {
    my $data = new_ok( 'Fritz::Data', [ 'FOO' ] );
    is( $data->error, '', 'get Fritz::Data instance');
    isa_ok( $data, 'Fritz::Data' );
    is( $data->get, 'FOO', 'Fritz::Data->name');
};

subtest 'check dump()' => sub {
    my $data = new_ok( 'Fritz::Data', [ 'TEST VALUE' ] );

    # only check first two lines!
    my $dump = $data->dump('xxx');
    foreach my $line ((split /\n/, $dump, 2)) { 
	like( $line, qr/^xxx/, 'line starts with given indent' );
    }

    $dump = $data->dump();
    foreach my $line ((split /\n/, $dump, 2)) {
	like( $line, qr/^(Fritz|----)/, 'line starts as expected' );
    }

    like( $dump, qr/Fritz::Data/, 'class name is dumped' );
    like( $dump, qr/TEST VALUE/, 'data is dumped' );
};

