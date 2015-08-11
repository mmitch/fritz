package Fritz::Service;
use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use SOAP::Lite; # +trace => [ transport => sub { print $_[0]->as_string } ]; # TODO: remove

use Data::Dumper; # TODO: remove

use Fritz::Action;
use Fritz::Data;

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

for my $attr (ATTRIBUTES) {
    has $attr => ( is => 'ro' );
}

sub BUILD {
    my $self = shift;

    my $xml  = $self->xmltree;

    for my $attr (ATTRIBUTES) {
	if (exists $xml->{$attr}) {
	    $self->{$attr} = $xml->{$attr}->[0];
	}
    }
}

sub _build_scpd {
    my $self = shift;

    my $url  = $self->fritz->upnp_url . $self->SCPDURL;

    my $response = $self->fritz->_ua->get($url);

    if ($response->is_success) {
	return Fritz::Data->new(
	    $self->fritz->_xs->parse_string($response->decoded_content)
	    );
    }
    else {
	return Fritz::Error->new($response->status_line);
    }
}

sub _build_action_hash {
    my $self = shift;

    my $scpd = $self->scpd;

    if ($scpd->error) {
	return {};
	# TODO: how to report this error? we return no object
    }
    else {
	my $hash = {};
	my $xml = $scpd->data->{actionList}->[0]->{action};

	foreach my $action (@{$xml}) {
	    $hash->{$action->{name}->[0]} = Fritz::Action->new(
		xmltree => $action
		);
	}
	return $hash;
    }
}

sub call {
    my $self      = shift;
    my $action    = shift;
    my %call_args = (@_);

    if (! exists $self->action_hash->{$action}) {
	return Fritz::Error->new("unknown action $action");
    }

    my $err = _hash_check(
	\%call_args,
	{ map { $_ => 0 } @{$self->action_hash->{$action}->args_in} },
	'unknown input argument',
	'missing input argument'
	);
    return $err if $err->error;

    my @args;
    foreach my $arg (keys %call_args) {
	push @args, SOAP::Data->name($arg)->value($call_args{$arg});
    }

    my $url = $self->fritz->upnp_url . $self->controlURL;

    my $soap = SOAP::Lite->new(
	proxy    => [ $url, ssl_opts => [ $self->fritz->_ua->ssl_opts ] ], # copy SSL settings from Fritz::_ua LWP::UserAgent
	uri      => $self->serviceType,
	readable => 1, # TODO: remove this
	);

    # expect the call to need authentication, so prepare an initial request
    my $auth = $self->_get_initial_auth;

    # SOAP::Lite just dies on transport error (eg. 401 Unauthorized), so eval this
    # TODO: send parameters
    my $som;
    eval {
	$som = $soap->call($action, @args, $auth);
    };

    # if we got a 503 authentication error: fine!
    # now we gots us a nonce and can retry
    if (! $@
	and $som->fault
	and exists $som->fault->{detail}->{UPnPError}->{errorCode}
	and $som->fault->{detail}->{UPnPError}->{errorCode} == 503) {

	if (defined $self->fritz->username
	    and defined $self->fritz->password) {

	    $auth = $self->_get_real_auth($som->headers);

	    eval {
		$som = $soap->call($action, @args, $auth);
	    };
	}
	else {
	    return Fritz::Error->new("authentication needed, but no credentials given");
	}
    }

    if ($@) {
	return Fritz::Error->new($@);
    }
    elsif ($som->fault) {
	my @error = ($som->fault->{faultcode}, $som->fault->{faultstring});
	if (exists $som->fault->{detail}->{UPnPError}) {
	    push @error, $som->fault->{detail}->{UPnPError}->{errorCode};
	    push @error, $som->fault->{detail}->{UPnPError}->{errorDescription};
	}
	return Fritz::Error->new(join ' ', @error);
    }
    else {
	# according to the docs, $som->paramsin returns an array of hashes.  I don't see this :-/
	my $args_out = $som->body->{$action.'Response'};
	$args_out = {} unless ref $args_out; # fix empty responses

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

sub dump {
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Service:\n";
    print "${indent}serviceType     = " . $self->serviceType . "\n";
    print "${indent}controlURL      = " . $self->controlURL  . "\n";
    print "${indent}SCPDURL         = " . $self->SCPDURL     . "\n";

    if ($self->action_hash) {
	print "${indent}actions         = {\n";
	foreach my $action (values %{$self->action_hash}) {
	    $action->dump($indent . '  ');
	}
	print "${indent}}\n";
    }
}

sub _get_initial_auth {
    my $self = shift;

    my $userid = SOAP::Header->name('UserID')
	->value($self->fritz->username);

    return SOAP::Header
	->name('h:InitChallenge')
	->attr({'xmlns:h' => 'http://soap-authentication.org/digest/2001/10/',
		's:mustUnderstand' => '1'})
	->value(\$userid);
}

sub _get_real_auth {
    my $self = shift;

    my $parm = shift;

    my $secret = md5_hex( join (':',
				$self->fritz->username,
				$parm->{Realm},
				$self->fritz->password,
			  ) );

    my $auth = SOAP::Header->name('Auth')
	->value(
	md5_hex( $secret . ':' . $parm->{Nonce} )
	);

    my $nonce = SOAP::Header->name('Nonce')
	->value($parm->{Nonce});

    my $realm = SOAP::Header->name('Realm')
	->value($parm->{Realm});

    my $userid = SOAP::Header->name('UserID')
	->value($self->fritz->username);

    return SOAP::Header
	->name('h:ClientAuth')
	->attr({'xmlns:h' => 'http://soap-authentication.org/digest/2001/10/',
		's:mustUnderstand' => '1'})
	->value(\SOAP::Header->value($nonce, $auth, $userid, $realm));
}

sub _hash_check {
    my ($hash_a, $hash_b, $msg_a, $msg_b) = (@_);

    foreach my $arg (keys %{$hash_a}) {
	if (! exists $hash_b->{$arg}) {
	    return Fritz::Error->new("$msg_a $arg");
	}
    }

    foreach my $arg (keys %{$hash_b}) {
	if (! exists $hash_a->{$arg}) {
	    return Fritz::Error->new("$msg_b $arg");
	}
    }

    return Fritz::Data->new();
}

1;
