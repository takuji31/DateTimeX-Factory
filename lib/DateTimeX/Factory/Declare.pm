package DateTimeX::Factory::Declare;
use strict;
use warnings;
use 5.010_000;

use Data::Validator;

use DateTimeX::Factory;

{
    my $FACTORY_CACHE = {};
    sub _factory_cache {$FACTORY_CACHE}
}
{

    my @METHODS = (
        [create => 'new'],
        qw/
            from_epoch
            now
            today
            yesterday
            tommorow
            last_day_of_month
            from_day_of_year
            strptime
            from_mysql_datetime
            from_mysql_date
            from_ymd
        /,
    );
    sub import {
        my $class  = shift;
        my $caller = caller;
        state $validator = Data::Validator->new(
            time_zone => {isa => 'DateTime::TimeZone', coerce => 1, xor => [qw/factory/], optional => 1},
            factory   => {isa => 'DateTimeX::Factory', xor => [qw/time_zone/], optional => 1},
        );
        my ($args) = $validator->validate(@_);

        my $time_zone = $args->{time_zone} if exists $args->{time_zone};
        my $factory;
        if(exists $args->{factory}) {
            $factory = $args->{factory};
        } elsif (exists $args->{time_zone}) {
            _factory_cache->{$time_zone->name} ||= DateTimeX::Factory->new(time_zone => $time_zone);
            $factory = _factory_cache->{$time_zone->name};
        } else {
            $factory = 'DateTimeX::Factory';
        }
        for my $meth (@METHODS) {
            my $origin = ref $meth ? $meth->[0] : $meth;
            my $alias  = ref $meth ? $meth->[1] : $meth;
            my $code = sub {
                $factory->$origin(@_);
            };
            {
                no strict 'refs';
                no warnings 'redefine';
                *{"$caller\::dt_$alias"} = $code;
            }
        }
    }
}

1;
__END__

=head1 NAME

DateTimeX::Factory::Declare - DateTimeX::Factory function interface.

=head1 VERSION

This document describes DateTimeX::Factory::Declare version 0.03.

=head1 SYNOPSIS

    use DateTimeX::Factory::Declare;

    DateTimeX::Factory->set_time_zone(DateTime::TimeZone->new(name => 'Asia/Tokyo'));
    my $dt = dt_new(year => 2011, month => 2, day => 1); #call DateTimeX::Factory->create
    my $now = dt_now;
    my $today = dt_today;
    my $yesterday = dt_yesterday;
    my $someday = dt_strptime('2011-02-01', '%F');

    #Set timezone
    use DateTimeX::Factory::Declare  (time_zone => 'Asia/Tokyo');

    #Use DateTimeX::Factory instance
    use DateTimeX::Factory;
    use DateTimeX::Factory::Declare  (factory => DateTimeX::Factory->new(time_zone => 'UTC'));


=head1 DESCRIPTION

DateTimeX::Factory function interface.

Can call DateTimeX::Factory method as dt_{method_name}(%params);

=head1 FUNCTIONS

=head2 C<< dt_new(%params) >>, C<< dt_now(%params) >>, C<< dt_today(%params) >>, C<< dt_from_epoch(%params) >>, C<< dt_last_day_of_month(%params) >>, C<< dt_from_day_of_year(%params) >>

See document of L<DateTime> and L<DateTimeX::Factory>.

=head2 C<< dt_strptime($string, $pattern) >>, C<< dt_from_mysql_datetime($string) >>, C<< dt_from_mysql_date($string) >>, C<< dt_from_ymd($string, $delimiter) >>

See document of L<DateTimeX::Factory>.


=head1 SEE ALSO

L<DateTimeX::Factory>

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji@senchan.jpE<gt>

=cut
