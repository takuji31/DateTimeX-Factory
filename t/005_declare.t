use strict;
use Test::More;

my @declare_methods = map {'dt_'.$_} qw/new from_epoch now today yesterday tommorow last_day_of_month strptime from_day_of_year from_mysql_date from_mysql_datetime from_ymd/;

package Mock::Simple;
use strict;
use warnings;

use DateTimeX::Factory::Declare;
use Test::More;

sub run {
    my $class = shift;
    can_ok $class, @declare_methods;
    my @time_zones = qw(
        Asia/Tokyo
        UTC
        floating
    );
    for my $tz (@time_zones) {
        DateTimeX::Factory->set_time_zone($tz);
        my $factory = DateTimeX::Factory->new(time_zone => $tz);

        is dt_now->time_zone->name => $tz,  "Correct time zone $tz";
        is dt_now() => $factory->now, 'datetime_now returns correct value';
        is dt_today() => $factory->today, 'datetime_today returns correct value';
        my $epoch = 100000000;
        is dt_from_epoch(epoch => $epoch) => $factory->from_epoch(epoch => $epoch), 'datetime_epoch returns correct value';
        my $fmt = '%Y%m%d%H%M%S';
        my $now = dt_now;
        is dt_strptime($now->strftime($fmt), $fmt) => $now, "strptime successful";

        $fmt = '%Y-%m-%d %H:%M:%S';
        is dt_from_mysql_datetime($now->strftime($fmt)) => $now, "from_mysql_datetime successful";
        $fmt = '%Y-%m-%d';
        is dt_from_mysql_date($now->strftime($fmt)) => $now->clone->truncate(to => 'day'), "from_mysql_date successful";
        $fmt = '%Y/%m/%d';
        is dt_from_ymd($now->strftime($fmt), '/') => $now->clone->truncate(to => 'day'), "from_ymd successful";

    }
}

package Mock::TimeZone;
use strict;
use warnings;

use DateTimeX::Factory::Declare time_zone => 'Asia/Tokyo';
use Test::More;

sub run {
    my $class = shift;
    can_ok $class, @declare_methods;
    my $factory = DateTimeX::Factory->new(time_zone => 'Asia/Tokyo');
    is dt_now->time_zone->name => 'Asia/Tokyo',  "Correct time zone Asia/Tokyo";
}

package Mock::Factory;
use strict;
use warnings;

use DateTimeX::Factory;
use DateTimeX::Factory::Declare factory => DateTimeX::Factory->new(time_zone => 'Asia/Tokyo');
use Test::More;

sub run {
    my $class = shift;
    can_ok $class, @declare_methods;
    my $factory = DateTimeX::Factory->new(time_zone => 'Asia/Tokyo');
    is dt_now->time_zone->name => 'Asia/Tokyo',  "Correct time zone Asia/Tokyo";
}

package main;


Mock::Simple->run;
Mock::TimeZone->run;
Mock::Factory->run;

done_testing;
