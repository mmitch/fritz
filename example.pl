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

