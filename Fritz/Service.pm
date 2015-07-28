package Fritz::Service;

use LWP::UserAgent;
use SOAP::Lite; # +trace => [ transport => sub { print $_[0]->as_string } ];

use Fritz::Action;
use Fritz::Data::XML;

use Moo;
use namespace::clean;

with 'Fritz::NoError';

has fritz        => ( is => 'ro' );

has xmltree      => ( is => 'ro' );
has scpd         => ( is => 'lazy' );
has action_hash  => ( is => 'lazy' );

use constant DEVICEINFO => 'urn:dslforum-org:service:DeviceInfo:1';

use constant ATTRIBUTES => qw(
serviceType
serviceId
controlURL
eventSubURL
SCPDURL
);

for my $attr (ATTRIBUTES)
{
    has $attr => ( is => 'ro' );
}

sub BUILD
{
    my $self = shift;

    my $xml  = $self->xmltree;

    for my $attr (ATTRIBUTES)
    {
	if (exists $xml->{$attr})
	{
	    $self->{$attr} = $xml->{$attr};
	}
    }
}

sub _build_scpd
{
    my $self    = shift;

    my $url = $self->fritz->upnp_url . $self->SCPDURL;

    my $ua = LWP::UserAgent->new();
    my $response = $ua->get($url);

    if ($response->is_success)
    {
	return Fritz::Data::XML->new($response->decoded_content);
    }
    else
    {
	return Fritz::Error->new($response->status_line);
    }
}

sub _build_action_hash
{
    my $self = shift;

    my $scpd = $self->scpd;

    if ($scpd->error)
    {
	return {};
	# TODO: how to report this error? we return no object
    }
    else
    {
	my $hash = {};
	my $xml = $scpd->data->{actionList}->{action};
	my @actions = keys %{$xml}; # TODO remove debugging

	# weird things in XML parsing: if there is only one argument, the argument_list hash element vanishes!
	# recreate it
	if (@actions == 2
	    and ref( $xml->{name} ) eq ''
	    and ref( $xml->{argumentList} ) eq 'HASH')
	{
	    @actions = ($xml->{name});
	    $xml = {
		$actions[0] => $xml
	    };
	}

	foreach my $action (@actions)
	{
	    $hash->{$action} = Fritz::Action->new(
		xmltree => $scpd->data->{actionList}->{action}->{$action},
		name    => $action
		);
	}
	return $hash;
    }
}

sub call
{
    my $self      = shift;
    my $action    = shift;
    my %call_args = (@_);

    if (! exists $self->action_hash->{$action})
    {
	return Fritz::Error->new("unknown action $action");
    }

    my $err = _hash_check(
	\%call_args,
	{ map { $_ => 0 } @{$self->action_hash->{$action}->args_in} },
	'unknown input argument',
	'missing input argument'
	);
    return $err if $err->error;

    my $url = $self->fritz->upnp_url . $self->controlURL;

    my $soap = SOAP::Lite->new(
	proxy    => $url,
	uri      => $self->serviceType,
	readable => 1 # TODO: remove this
	);

    # SOAP::Lite just dies on transport error (eg. 401 Unauthorized), so eval this
    # TODO: send parameters
    my $som;
    eval {
	$som = $soap->call($action);
    };

    if ($@)
    {
	return Fritz::Error->new($@);
    }
    elsif ($som->fault)
    {
	return Fritz::Error->new($som->fault->faultcode . ' ' . $som->fault->faultstring);
    }
    else
    {
	# according to the docs, $som->paramsin returns an array of hashes.  I don't see this :-/
	my $args_out = $som->body->{$action.'Response'};

	$err = _hash_check(
	    $args_out,
	    { map { $_ => 0 } @{$self->action_hash->{$action}->args_out} },
	    'unknown output argument',
	    'missing output argument'
	    );
	return $err if $err->error;

	return Fritz::Data->new($args_out);
    }
}

sub dump
{
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Service:\n";
    print "${indent}serviceType     = " . $self->serviceType . "\n";
    print "${indent}controlURL      = " . $self->controlURL  . "\n";
    print "${indent}SCPDURL         = " . $self->SCPDURL     . "\n";

    if ($self->action_hash)
    {
	print "${indent}actions         = {\n";
	foreach my $action (values %{$self->action_hash})
	{
	    $action->dump($indent . '  ');
	}
	print "${indent}}\n";
    }
}

sub _hash_check
{
    my ($hash_a, $hash_b, $msg_a, $msg_b) = (@_);

    foreach my $arg (keys %{$hash_a})
    {
	if (! exists $hash_b->{$arg})
	{
	    return Fritz::Error->new("$msg_a $arg");
	}
    }

    foreach my $arg (keys %{$hash_b})
    {
	if (! exists $hash_a->{$arg})
	{
	    return Fritz::Error->new("$msg_b $arg");
	}
    }

    return Fritz::Data->new();
}

1;
