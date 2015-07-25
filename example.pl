#!/usr/bin/perl -w
use warnings;
use strict;

use Fritz;

my $f = Fritz->new();

$f->dump();
print "\n\n";

my $d = $f->discover();

$d->dump();
print "\n\n";

my $s = $d->find_service( 'urn:dslforum-org:service:WANDSLInterfaceConfig:1' );

$s->dump();
print "\n\n";

my $s = $d->find_service( Fritz::Service::DEVICEINFO );

$s->dump();
print "\n\n";

#use Data::Dumper;
#print Dumper( $s->scpd() );

my $r = $s->call('GetSecurityPort');

$r->dump();

