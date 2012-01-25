use strict;
use Test::More;

use DateTimeX::Factory;

my @time_zones = qw(
    Asia/Tokyo
    UTC
    floating
);
subtest "instance method" => sub {

    for my $tz (@time_zones) {
        my $instance = DateTimeX::Factory->new(
            time_zone => $tz,
        );
        is($instance->now->time_zone->name => $tz, "Correct time zone $tz from instance method");
    }

};

subtest "class method" => sub {

    for my $tz (@time_zones) {
        local $DateTimeX::Factory::TIME_ZONE = DateTime::TimeZone->new(name => $tz);
        is(DateTimeX::Factory->now->time_zone->name => $tz, "Correct time zone $tz from class method");
    }

};

done_testing;
