package Fritz;
use strict;
use warnings;

=head1 NAME

Fritz - AVM Fritz!Box interaction via TR-064

=head1 VERSION

0.0.1

=head1 SYNOPSIS

    use Fritz::Box;

    my $fritz = Fritz::Box->new();
    if ($fritz->error) {
        die $fritz->error;
    }

    my $device = $fritz->discover();
    $device->errorcheck;

    my $service = $device->find_service('DeviceInfo:1');
    $service->errorcheck;

    my $response = $service->call('GetSecurityPort');
    $response->errorcheck;

    printf "SSL communication port is %d\n",
           $response->data->{NewSecurityPort};

    # dump all available devices and services
    Fritz::Box->new()->discover()->dump();

You also need to enable TR-064 on your Fritz!Box, see
L</"CONFIGURATION AND ENVIRONMENT">.

=head1 DESCRIPTION

L<Fritz> is a set of modules to communicate with an AVM Fritz!Box (and
possibly other routers as well) via the TR-064 protocol.

I wanted to initiate calls via commandline, but I only found GUI tools
to do that or libraries in other langages than Perl, so I have built
this library.

Luckily, the TR-064 protocol announces all available services via XML.
So this module does some HTTP or HTTPS requests to find the router,
query it's services and then calls them via SOAP.  Parameter names and
counts are verified against the service specification, but L<Fritz>
itself knows nothing about the available services or what they do.

=head1 INTERFACE

L<Fritz::Box> is the main entry point and initializes a basic object
with some configuration information (URL of the Fritz!Box,
authentication data etc.).  Use the C<discover()> method to get a

L<Fritz::Device> which represents your router.  A device may contain
further L<Fritz::Device> subdevices, eg. a LAN or WAN interface.  But
most importantly, a device should contain at least

L<Fritz::Service> on which different methods can be C<call()>ed to set
or read parameters or do various things.  A method call will return

L<Fritz::Data> which is a simple wrapper about the data returned
(normally a hash containing all return values from the called
service).

L<Fritz::Error> is returned instead of the ofter objects whenever
something goes wrong.

Finally, there is L<Fritz::IsNoError>, which is just a role to provide
all valid (non-error) objects with C<error> and C<errorcheck()> so
that you can query every Fritz:: object for its error state.

=head1 CONFIGURATION AND ENVIRONMENT

To set up your Fritz!Box, you have to enable the remote administration
via TR-064 in the web administration interface.

Nearly all services except C<GetSecurityPort> from the example above
need authentication.  The best way to achieve this is to add an extra
user with its own password (again via the web administration
interface).  The user needs the permission to change and edit the
Fritz!Box configuration.  If you want to call the VoIP services, it
needs that permission as well.  Then use the I<username> and
I<password> parameters to C<Fritz::Box->new()>.

=head1 BUGS AND LIMITATIONS

=head2 SSL

A Fritz!Box does not generate 'valid' SSL certificates but self-signed
ones.  Depending on your Perl setup, this will result in errors like
C<certificate verification failed> when trying to discover
L<Fritz::Device>s or L<Fritz::Service>s.  L<Fritz::Box> tries to set
up a L<LWP::UserAgent> instance that ignores certificate errors, but
more often than not this fails.  (Currently, this might even fail one
time and work the next I<on the same system>!  Don't know what's going
on there.)

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 by  Christian Garbs <mitch@cgarbs.de>
Licensed under GNU GPL v2 or later.

=head1 AVAILABILITY

=over

=item github repository: L<git://github.com/mmitch/fritz.git>

=item github browser: L<https://github.com/mmitch/fritz>

=item github issue tracker: L<https://github.com/mmitch/fritz/issues>

=back

=head1 AUTHOR

Christian Garbs <mitch@cgarbs.de>

=head1 SEE ALSO

L<AVM interface documentation|http://avm.de/service/schnittstellen/>

=cut

1;
