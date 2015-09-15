package Fritz::Device;
use strict;
use warnings;

use Fritz::Data;
use Fritz::Error;
use Fritz::Service;

use Moo;
use namespace::clean;

with 'Fritz::IsNoError';

=head1 NAME

Fritz::Device - represents a TR064 device

=head1 SYNOPSIS

    my $fritz    = Fritz::Box->new();
    my $device   = $fritz->discover();

    # get services to call them later
    my $service_a = $device->get_service('DeviceInfo:1');
    my $service_b = $device->find_service('D.*Info:1');

    # get a subdevice
    my $subdevice = $device->find_device('LANDevice:1');

    # this one can give multiple results
    my $service_list = $device->find_service_names('DeviceInfo:1');
    printf "%d services found\n",
           scalar @{$service_list->data};

    # show all data
    $device->dump();

=head1 DESCRIPTION

This class represents a TR064 device that has been discovered.  A
device gives access to other subdevices (L<Fritz::Device>) as well as
L<Fritz::Service>s which allow interaction with a L<Fritz::Device>.

=head1 ATTRIBUTES (read-only)

=head2 fritz

A L<Fritz::Box> instance containing the current configuration
information (device address, authentication etc.).

=cut

has fritz        => ( is => 'ro' );

=head2 xmltree

A complex hashref containing all information about this
L<Fritz::Device>.  This is the parsed form of the TR064 XML which
describes the device, it's subdevices and L<Fritz::Service>s.

=cut

has xmltree      => ( is => 'ro' );

=head2 service_list

An arrayref of all L<Fritz::Service>s that are available on this
device.

=cut

has service_list => ( is => 'lazy', init_arg => undef );

sub _build_service_list {
    my $self = shift;
    my $xml  = $self->xmltree;
    my @services;

    if (exists $xml->{serviceList}) {
	foreach my $service (@{$xml->{serviceList}->[0]->{service}}) {
	    push @services, Fritz::Service->new(
		xmltree => $service,
		fritz   => $self->fritz
		);
	}
    }

    return \@services;
}

=head2 device_list

An arrayref of all subdevices (L<Fritz::Device>) that are available on
this device.

=cut

has device_list  => ( is => 'lazy', init_arg => undef );

sub _build_device_list {
    my $self = shift;
    my $xml  = $self->xmltree;
    my @devices;

    if (exists $xml->{deviceList}) {
	foreach my $device (@{$xml->{deviceList}->[0]->{device}}) {
	    push @devices, Fritz::Device->new(
		xmltree => $device,
		fritz   => $self->fritz
		);
	}
    }

    return \@devices;
}

=head2 attributes

A hashref that contains the most important information from the XML
device description.  This allows easier access than via L</xmltree>.
The available attributes are device-dependent.  The following
attributes are made available as keys in the hashref if present in the
XML:

=over 4

=item deviceType

=item friendlyName

=item manufacturer

=item manufacturerURL

=item modelDescription

=item modelName

=item modelNumber

=item modelURL

=item UDN

=item presentationURL

=back

=cut

has attributes   => ( is => 'lazy', init_arg => undef );

use constant ATTRIBUTES => qw(
deviceType
friendlyName
manufacturer
manufacturerURL
modelDescription
modelName
modelNumber
modelURL
UDN
presentationURL
);

sub _build_attributes {
    my $self = shift;
    my $xml  = $self->xmltree;
    my $attributes = {};

    for my $attr (ATTRIBUTES) {
	if (exists $xml->{$attr}) {
	    $attributes->{$attr} = $xml->{$attr}->[0];
	}
    }

    return $attributes;
}

=head2 error

See L<Fritz::IsNoError/error>.

=head1 METHODS

=head2 new

Creates a new L<Fritz::Device> object.  You propably don't have to call
this method, it's mostly used internally.  Expects parameters in C<key
=E<gt> value> form with the following keys:

=over

=item I<fritz>

L<Fritz::Box> configuration object

=item I<xmltree>

device information in parsed XML format

=back

=head2 get_service(I<name>)

Returns the L<Fritz::Service> whose
L<serviceType|Fritz::Service/serviceType> equals I<name>.

If no matching service is found, the subdevices are searched for the
service in the order they are listed in the device XML, depth first.

If no matching service is found, a L<Fritz::Error> is returned.

=cut

sub get_service {
    my $self = shift;
    my $type = shift;

    foreach my $service (@{$self->service_list}) {
	if ($service->serviceType eq $type) {
	    return $service;
	}
    }

    foreach my $device (@{$self->device_list}) {
	my $service = $device->get_service($type);
	if (! $service->error) {
	    return $service;
	}
    }
    
    return Fritz::Error->new('service not found');
}

=head2 find_service(I<regexp>)

Returns the L<Fritz::Service> whose
L<serviceType|Fritz::Service/serviceType> matches I<regexp>.

If no matching service is found, the subdevices are searched for the
service in the order they are listed in the device XML, depth first.

If no matching service is found, a L<Fritz::Error> is returned.

=cut

sub find_service {
    my $self = shift;
    my $type = shift;

    foreach my $service (@{$self->service_list}) {
	if ($service->serviceType =~ /$type/) {
	    return $service;
	}
    }

    foreach my $device (@{$self->device_list}) {
	my $service = $device->find_service($type);
	if (! $service->error) {
	    return $service;
	}
    }

    return Fritz::Error->new('service not found');
}

=head2 find_service_names(I<regexp>)

Returns all L<Fritz::Service>s whose
L<serviceType|Fritz::Service/serviceType> match I<regexp>.

Searches recursively through all subdevices in the order they are
listed in the device XML, depth first.

The resulting arrayref is wrapped in a L<Fritz::Data> to allow L<error
checking|Fritz::IsNoError>.

=cut

sub find_service_names {
    my $self = shift;
    my $type = shift;

    my @found = ();

    foreach my $service (@{$self->service_list}) {
	if ($service->serviceType =~ /$type/) {
	    push @found, $service;
	}
    }

    foreach my $device (@{$self->device_list}) {
	my $data = $device->find_service_names($type);
	if (! $data->error) {
	    push @found, @{$data->data};
	}
    }

    return Fritz::Data->new(\@found);
}

=head2 find_device(I<name>)

Returns the L<Fritz::Device> subdevice whose I<deviceType> equals
I<name>.

If no matching service is found, the subdevices are searched for the
I<deviceType> in the order they are listed in the device XML, depth
first.

If no matching device is found, a L<Fritz::Error> is returned.

=cut

sub find_device {
    my $self = shift;
    my $type = shift;

    foreach my $device (@{$self->device_list}) {
	if ($device->deviceType eq $type) {
	    return $device;
	}
    }
    
    foreach my $device (@{$self->device_list}) {
	my $device = $device->find_device($type);
	if (! $device->error) {
	    return $device;
	}
    }
    
    return Fritz::Error( error => 'device not found' );
}

=head2 dump(I<indent>)

C<print()> some information about the object.  Useful for debugging
purposes.  The optional parameter I<indent> is used for indentation of
the output by prepending it to every line.

Recursively descends into subdevices and services, so dumping the root
device of a L<Fritz::Box/discover> should show everything that is
available.

=cut

sub dump {
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Device:\n";
    $indent .= '  ';
    print "${indent}modelName       = " . $self->attributes->{modelName} . "\n";
    print "${indent}presentationURL = " . $self->attributes->{presentationURL} . "\n" if defined $self->attributes->{presentationURL};

    if ($self->service_list) {
	print "${indent}subservices    = {\n";
	foreach my $service (@{$self->service_list}) {
	    $service->dump($indent . '  ');
	}
	print "${indent}}\n";
    }

    if ($self->device_list) {
	print "${indent}subdevices      = {\n";
	foreach my $device (@{$self->device_list}) {
	    $device->dump($indent . '  ');
	}
	print "${indent}}\n";
    }
}

=head2 errorcheck

See L<Fritz::IsNoError/errorcheck>.

=head1 BUGS AND LIMITATIONS

B<TODO:> Method names are inconsistent: With services, C<get_*> uses
exact matching while C<find_*> uses regexp matching.  But with
devices, L</find_device> uses exact matching.  Change this to match
the service methods and add the missing variants.

B<TODO:> Rename L</find_service_names> to something like
L</find_all_service> as it's basically L</find_service> with multiple
results.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 by  Christian Garbs <mitch@cgarbs.de>
Licensed under GNU GPL v2 or later.

=head1 AUTHOR

Christian Garbs <mitch@cgarbs.de>

=head1 SEE ALSO

See L<Fritz> for general information about this package, especially
L<Fritz/INTERFACE> for links to the other classes.

=cut

1;
