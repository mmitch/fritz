#!perl
use Test::More tests => 6;
use warnings;
use strict;

use Cwd qw(abs_path);

BEGIN { use_ok('Fritz::Box') };

my $trdesc_file;
for my $file ( qw(fake_tr64desc.xml t/fake_tr64desc.xml) ) {
    $trdesc_file = abs_path($file) if -r $file;
}
isnt( $trdesc_file, undef, 'find fake TR64 XML file');

my $box = new_ok( 'Fritz::Box', [
		      upnp_url => 'file://',
		      trdesc_path => $trdesc_file
		  ] );
is( $box->error, '', 'get Fritz::Box' );

my $device = $box->discover();
is( $device->error, '', 'get Fritz::Device' );

is( $device->attributes->{friendlyName}, 'UnitTest Unit', 'check friendlyName' );
