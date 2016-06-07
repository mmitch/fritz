#!perl
use Test::More tests => 6;
use warnings;
use strict;

BEGIN { use_ok('Net::Fritz::Data') };


### public tests

subtest 'check data getter' => sub {
    # given
    my $value = 'barf00';
    my $data = new_ok( 'Net::Fritz::Data', [ data => $value ] );

    # when
    my $result = $data->data();

    # then
    is( $result, $value, 'Net::Fritz::Data->data');
};

subtest 'check get()' => sub {
    # given
    my $value = 'FOObar';
    my $data = new_ok( 'Net::Fritz::Data', [ $value ] );

    # when
    my $result = $data->get();

    # then
    is( $result, $value, 'Net::Fritz::Data->get');
};

subtest 'check dump()' => sub {
    my $data = new_ok( 'Net::Fritz::Data', [ 'TEST VALUE' ] );

    # only check first two lines!
    my $dump = $data->dump('xxx');
    foreach my $line ((split /\n/, $dump, 2)) { 
	like( $line, qr/^xxx/, 'line starts with given indent' );
    }

    $dump = $data->dump();
    foreach my $line ((split /\n/, $dump, 2)) {
	like( $line, qr/^(Net::Fritz|----)/, 'line starts as expected' );
    }

    like( $dump, qr/Net::Fritz::Data/, 'class name is dumped' );
    like( $dump, qr/TEST VALUE/, 'data is dumped' );
};


### internal tests

subtest 'check new() with named parameters' => sub {
    # given
    my $value = 'foo';

    # when
    my $data = new_ok( 'Net::Fritz::Data', [ data => $value ] );

    # then
    is( $data->data, $value, 'Net::Fritz::Data->data');
};

subtest 'check new() with single parameter' => sub {
    # given
    my $value = 'bar';

    # when
    my $data = new_ok( 'Net::Fritz::Data', [ $value ] );

    # then
    is( $data->data, $value, 'Net::Fritz::Data->data');
};

