#!perl
use Test::More tests => 2;
use warnings;
use strict;

BEGIN { use_ok('Fritz::IsNoError') };

# new()
eval {
    my $error = Fritz::IsNoError->new();
};
like( $@, qr(Can't locate object method), 'role has no new() method' );
