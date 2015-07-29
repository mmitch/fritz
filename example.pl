#!/usr/bin/perl -w
use warnings;
use strict;

use Fritz;

use Data::Dumper;

use utf8;

# get credentials (not checked in)
my ($user, $pass);
my $rcfile = $ENV{HOME}.'/.fritzrc';
if (-r $rcfile)
{
    open FRITZRC, '<', $rcfile or die $!;
    while (my $line = <FRITZRC>)
    {
	chomp $line;
	if ($line =~ /^(\S+)\s*=\s*(.*?)$/)
	{
	    warn "<$1> -> <$2>\n";
	    if ($1 eq 'username')
	    {
		$user = $2;
	    }
	    elsif ($1 eq 'password')
	    {
		$pass = $2
	    }
	}
    }
    close FRITZRC or die $!;
    # TODO: move ~/.fritzrc parsing to Fritz.pm?
}

my $f = Fritz->new(
    username => $user,
    password => $pass
    );

$f->dump();
print "\n\n";

my $d = $f->discover();
# $d->dump();
print "\n\n";

my $s = $d->find_service( 'urn:dslforum-org:service:WANDSLInterfaceConfig:1' );
$s->dump();
print "\n\n";

$s = $d->find_service( Fritz::Service::DEVICEINFO );
$s->dump();
print "\n\n";

my $r;

#print Dumper( $s->scpd() );

#$r = $s->call('GetSecurityPort');
#$r->dump();
#print "the security port is " . $r->data->{'NewSecurityPort'} . "\n\n";

$r = $s->call('GetInfo');

print Dumper($r);

#$s = $d->find_service( 'urn:dslforum-org:service:X_VoIP:1' );
#print Dumper($s->dump);
#print Dumper($s->call('X_AVM-DE_DialHangup'));
