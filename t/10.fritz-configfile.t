#!perl
use Test::More tests => 9;
use warnings;
use strict;

use Test::TempDir::Tiny;

use File::Basename;
use File::Path qw(make_path);

BEGIN { use_ok('Net::Fritz::ConfigFile') };


### public tests

subtest 'check new()' => sub {
    # given

    # when
    my $config = new_ok( 'Net::Fritz::ConfigFile' );

    # then
    is( $config->configfile, undef,           'Net::Fritz::ConfigFile->configfile' );
};

subtest 'check new() with named parameters' => sub {
    # given

    # when
    my $config = new_ok( 'Net::Fritz::ConfigFile',
		      [ configfile  => 't/config.file' ]
	);
    
    # then
    is( $config->configfile, 't/config.file', 'Net::Fritz::ConfigFile->configfile' );
};

subtest 'check new() with single parameter' => sub {
    # given

    # when
    my $config = new_ok( 'Net::Fritz::ConfigFile', [ 't/config.file' ] );
    
    # then
    is( $config->configfile, 't/config.file', 'Net::Fritz::ConfigFile->configfile' );
};

subtest 'configuration() returns configfile content' => sub {
    # given
    my $config = new_ok( 'Net::Fritz::ConfigFile', [ 't/config.file' ]);

    # when
    my $vars = $config->configuration;

    # then
    is_deeply( $vars,
	       {
		   upnp_url => 'UPNP',
		   trdesc_path => 'TRDESC',
		   username => 'USER',
		   password => 'PASS'
	       },
	       'configuration data' );
};

subtest 'empty configfile returns empty configuration' => sub {
    # given
    my $config = new_ok( 'Net::Fritz::ConfigFile', [ 't/empty.file' ]);

    # when
    my $vars = $config->configuration;

    # then
    is_deeply( $vars, {}, 'configuration data' );
};


subtest '~ is expanded to $HOME in configfile name' => sub {
    # given
    ok( exists $ENV{HOME}, '$HOME is set' );

    # when
    my $config = new_ok( 'Net::Fritz::ConfigFile', [ '~/config.file' ] );

    # then
    is( $config->configfile, "$ENV{HOME}/config.file", 'Net::Fritz::ConfigFile->configfile' );
};

subtest 'use ~/.fritzrc as default configfile if filename is not set' => sub {
    # given
    # ensure that ~/.fritzrc exists
    $ENV{HOME} = tempdir();
    touch_file("$ENV{HOME}/.fritzrc");

    # when
    my $config = new_ok( 'Net::Fritz::ConfigFile', [ 0 ] );

    # then
    is( $config->configfile, "$ENV{HOME}/.fritzrc", 'Net::Fritz::Box->configfile' );
    is_deeply( $config->configuration, {}, 'configuration data' );
};

subtest 'missing default configfile is skipped and throws no error' => sub {
    # given
    # set $HOME to empty temporary directory
    # to be sure that no ~/.fritzrc exists
    $ENV{HOME} = tempdir();
    
    # when
    my $config = new_ok( 'Net::Fritz::ConfigFile', [ 0 ] );

    # then
    is( $config->configfile, 0, 'Net::Fritz::Box->configfile' );
};


### internal tests


### helper methods

sub touch_file
{
    my $file = shift;

    my $dir = dirname($file);
    make_path $dir unless -d $dir;
    
    open EMPTYFILE, '>', $file or die $!;
    close EMPTYFILE or die $!;    
}
