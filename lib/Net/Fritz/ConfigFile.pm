use strict;
use warnings;
# Copyright (C) 2017  Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL v2 or later.

package Net::Fritz::ConfigFile;
# ABSTRACT: configuration file handler for L<Net::Fritz::Box>


use AppConfig;
use File::Spec;

use Moo;

=head1 SYNOPSIS

    my $config = Net::Fritz::ConfigFile->new( 'some/dir/fritzrc' );
    my $config_hashref = $config->configuration;

=head1 DESCRIPTION

This class encapsulates the configuration file handling for
L<Net::Fritz::Box>.  It should not be needed to directly interact with
this class.  No user-serviceable parts inside!

This class is available since C<v0.0.9>.

=head1 CONFIGURATION FILE FORMAT

The configuration format is basically a flat text file with C<key =
value> per line.  Empty lines as well as comments (prefixed by C<#>)
are supported.

These keys are recognized:

=over

=item * L<upnp_url|Net::Fritz::Box/upnp_url>

=item * L<trdesc_path|Net::Fritz::Box/trdesc_path>

=item * L<username|Net::Fritz::Box/username>

=item * L<password|Net::Fritz::Box/password>

=back

(L<AppConfig> is used to read the configuration file, so some advanced
tricks might be possible.)

=head1 DEFAULT CONFIGURATION FILE LOCATIONS

If the given configuration filename expands to false, these default
configuration file locations are tried instead (in order):

=over 4

=item 1. C<$XDG_CONFIG_HOME/fritzrc> (only if C<$XDG_CONFIG_HOME> is set)

=item 2. C<~/.config/fritzrc>

=item 3. C<~/.fritzrc>

=back

The first existing file will be used.

=cut

sub _find_default_configfile {
    my $original = shift;

    my $try;

    if (exists $ENV{XDG_CONFIG_HOME}) {
	$try = File::Spec->catfile( $ENV{XDG_CONFIG_HOME}, 'fritzrc' );
	return $try if -e $try;
    }

    $try = File::Spec->catfile( $ENV{HOME}, '.config', 'fritzrc' );
    return $try if -e $try;

    $try = File::Spec->catfile( $ENV{HOME}, '.fritzrc' );
    return $try if -e $try;

    return $original;
}

=head1 ATTRIBUTES (read-only)

=head2 configfile

Default value: none

Sets a configuration file to read the configuration from.

A C<~> at the beginning of the filename will be expanded to
C<$ENV{HOME}>.

If the filename expands to C<false> (C<0>, C<''> or the like), the
L<default configuration file locations|/DEFAULT CONFIGURATION FILE
LOCATIONS> will be tried.  If none of those files exists, an empty
configuration file is substituted.

=cut

has configfile    => ( is => 'ro' , coerce => sub {

    my $configfile = shift;

    # expand empty filename to default ~/.fritzrc
    if (! $configfile) {
	$configfile = _find_default_configfile($configfile);
    }

    # expand ~ to $HOME
    $configfile =~ s/^~/$ENV{HOME}/;

    return $configfile;

} );



=head2 configuration

Default value: none

The configuration values from the configuration file as a hashref.

Keys that were not present in the configuration file are not returned.

=cut
    
has configuration => ( is => 'lazy' );

sub _build_configuration {

    my $self = shift;

    return {} unless $self->configfile;

    my $app_config = AppConfig->new();
    $app_config->define('upnp_url=s');
    $app_config->define('trdesc_path=s');
    $app_config->define('username=s');
    $app_config->define('password=s');

    $app_config->file($self->configfile);

    my %config_vars = $app_config->varlist('^');

    # remove all missing configuration variables
    delete $config_vars{$_} foreach grep {!defined $config_vars{$_}} keys %config_vars;

    return \%config_vars;
};

=head1 METHODS

=head2 new

Creates a new L<Net::Fritz::ConfigFile> object.  Expects parameters in
C<key =E<gt> value> form with the following keys to overwrite the
default values:

=over

=item * L</configfile>

=back

With only one parameter (in fact: any odd value of parameters), the
first parameter is automatically mapped to L</configfile>.

=for Pod::Coverage BUILDARGS

=cut

# prepend 'configfile => ' when called without hash
# (when called with uneven list)
sub BUILDARGS {
    my ( $class, @args ) = @_;
    
    unshift @args, "configfile" if @args % 2 == 1;
    
    return { @args };
};

=head1 SEE ALSO

See L<Net::Fritz> for general information about this package,
especially L<Net::Fritz/INTERFACE> for links to the other classes.

=cut

1;
