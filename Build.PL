use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Fritz::Box',
    dist_license             => 'gpl_2',
    dist_author         => 'Christian Garbs <mitch@cgarbs.de>',
    dist_version_from   => 'lib/Fritz/Box.pm',
    dist_abstract       => 'AVM Fritz!Box interaction via TR-064',
    configure_requires => {
	'Module::Build' => 0.40,
    },
    requires => {
	'Digest::MD5' => 0,
	'LWP::UserAgent' => 0,
	'Moo' => 0,
	'SOAP::Lite' => 0,
	'XML::Simple' => 0,
	'namespace::clean' => 0,
    },
    test_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Fritz-Box-*' ],
);

$builder->create_build_script();
