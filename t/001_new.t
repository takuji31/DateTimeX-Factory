use strict;
use Test::More;

use DateTime::Factory;

my $instance = DateTime::Factory->new(
    time_zone => 'floating',
);
isa_ok($instance => 'DateTime::Factory', 'new method returns object');

done_testing;
