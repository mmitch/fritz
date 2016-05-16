#!perl
use Test::More tests => 4;
use warnings;
use strict;

use Test::Exception;

BEGIN { use_ok('Fritz::IsNoError') };


### public tests

subtest 'check stub role' => sub {
    # given

    # when
    my $obj = get_stub();

    # then
    ok( $obj->does('Fritz::IsNoError'), 'does Fritz::IsNoError role' );
};

subtest 'check error getter' => sub {
    # given
    my $obj = get_stub();

    # when
    my $result = $obj->error;

    # then
    is( $result, '', 'error message is empty' );
};

subtest 'check errorcheck()' => sub {
    # given
    my $obj = get_stub();

    # when/then
    lives_ok( sub { $obj->errorcheck() }, 'errorcheck() does not die' );
};


### helper methods

sub get_stub
{
    # a role has no constructor, so we need a dummy class
    {
	package Fritz::IsNoError::Stub;
	use Moo;
	with 'Fritz::IsNoError';
    }

    return Fritz::IsNoError::Stub->new;
}
