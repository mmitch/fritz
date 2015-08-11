use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Fritz::Box',
    license             => 'gpl2',
    dist_author         => 'Christian Garbs <mitch@cgarbs.de>',
    dist_version_from   => 'lib/Fritz/Box.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Fritz-Box-*' ],
);

$builder->create_build_script();
