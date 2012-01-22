use strict;
use Test::More;

use DateTime::Factory;

my @time_zones = qw(
    Asia/Tokyo
    UTC
    floating
);
subtest "instance method" => sub {

    for my $tz (@time_zones) {
        my $instance = DateTime::Factory->new(
            time_zone => $tz,
        );
        is($instance->now->time_zone->name => $tz, "Correct time zone $tz from instance method");
    }

};

subtest "class method" => sub {

    for my $tz (@time_zones) {
        local $DateTime::Factory::TIME_ZONE = DateTime::TimeZone->new(name => $tz);
        is(DateTime::Factory->now->time_zone->name => $tz, "Correct time zone $tz from class method");
    }

};

done_testing;
