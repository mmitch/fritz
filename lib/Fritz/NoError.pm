package Fritz::NoError;
use strict;
use warnings;

use Moo::Role;
use namespace::clean;

has error => ( is => 'ro', default => 0 );

sub errorcheck {
}

1;
