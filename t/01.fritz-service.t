#!perl
use Test::More tests => 11;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Service') };

# prepare XML tree data

my $xmltree = {
    'serviceType' => [ 'S_TYPE' ],
    'serviceId' => [ 'S_ID' ],
    'controlURL' => [ 'C_URL' ],
    'eventSubURL' => [ 'ES_URL' ],
    'SCPDURL' => [ 'SCPD_URL' ],
    'fake_key' => [ 'does_not_exist' ]
};


# new() with named parameters
my $service = new_ok( 'Fritz::Service', [ fritz => 'fake', xmltree => $xmltree ] );
is( $service->error, '', 'get Fritz::Service instance');
isa_ok( $service, 'Fritz::Service' );

is( $service->fritz, 'fake', 'Fritz::Service->fritz' );

for my $key (keys %{$xmltree}) {
    next if $key =~ /^fake/;
    is( $service->$key, $xmltree->{$key}->[0], "Fritz::Service->$key" );
}
for my $key (keys %{$xmltree}) {
    next unless $key =~ /^fake/;
    ok( ! exists $service->{$key}, "Fritz::Service->$key does not exist" );
}

