package Fritz::NoError;

use Moo::Role;
use namespace::clean;

has error => ( is => 'ro', default => 0 );

1;