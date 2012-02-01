package DateTimeX::Factory;
use 5.010_000;
use strict;
use warnings;

our $VERSION = '0.03';

use Data::Validator;
use DateTime;
use DateTime::TimeZone;
use DateTime::Format::Strptime;

my  $DEFAULT_TIME_ZONE = DateTime::TimeZone->new(name => 'floating');
our $TIME_ZONE = $DEFAULT_TIME_ZONE;

use Mouse::Util::TypeConstraints;

#avoid redefine error
eval { class_type('DateTime::TimeZone') };

coerce 'DateTime::TimeZone' => from 'Str' => via { DateTime::TimeZone->new(name => $_) };

no Mouse::Util::TypeConstraints;
use Mouse;

has time_zone => (is => 'rw', isa => 'DateTime::TimeZone', coerce => 1, default => sub { $DEFAULT_TIME_ZONE });

no Mouse;


{
    my @METHODS = (
        [new => 'create'],
        qw/
            from_epoch
            now
            today
            last_day_of_month
            from_day_of_year
        /,
    );
    for my $meth (@METHODS) {
        my $origin = ref $meth ? $meth->[0] : $meth;
        my $alias  = ref $meth ? $meth->[1] : $meth;
        my $code = sub {
            my $invocant = shift;
            DateTime->$origin($invocant->_default_options, @_);
        };
        {
            no strict 'refs';
            *{__PACKAGE__."::".$alias} = $code;
        }
    }
}

sub strptime {
    state $validator = Data::Validator->new(
        string  => {isa => 'Str'},
        pattern => {isa => 'Str'},
    )->with(qw/Method Sequenced/);
    my ($invocant, $args) = $validator->validate(@_);
    return DateTime::Format::Strptime->new(
        pattern => $args->{pattern},
        $invocant->_default_options,
    )->parse_datetime($args->{string});
}

sub from_mysql_datetime {
    state $validator = Data::Validator->new(
        string  => {isa => 'Str'},
    )->with(qw/Method Sequenced/);
    my ($invocant, $args) = $validator->validate(@_);
    return if $args->{string} eq '0000-00-00 00:00:00';
    return $invocant->strptime($args->{string}, '%Y-%m-%d %H:%M:%S');
}

sub from_ymd {
    state $validator = Data::Validator->new(
        string  => {isa => 'Str'},
        delimiter => {isa => 'Str', default => '-'},
    )->with(qw/Method Sequenced/);
    my ($invocant, $args) = $validator->validate(@_);
    return $invocant->strptime($args->{string}, join $args->{delimiter}, '%Y','%m','%d');
}

sub from_mysql_date {
    state $validator = Data::Validator->new(
        string  => {isa => 'Str'},
    )->with(qw/Method Sequenced/);
    my ($invocant, $args) = $validator->validate(@_);
    return if $args->{string} eq '0000-00-00';
    return $invocant->from_ymd($args->{string});
}

sub yesterday {shift->today(@_)->subtract(days => 1)}
sub tommorow  {shift->today(@_)->add(days => 1)}

sub _default_options {
    my $invocant = shift;
    my %options = (time_zone => ref $invocant ? $invocant->time_zone : $TIME_ZONE);
    return %options;
}

sub set_time_zone {
    state $validator = Data::Validator->new(
        time_zone => {isa => 'DateTime::TimeZone', coerce => 1, default => sub{$DEFAULT_TIME_ZONE}},
    )->with(qw/Method Sequenced/);
    my ($invocant, $args) = $validator->validate(@_);
    if(ref $invocant) {
        $invocant->time_zone($args->{time_zone});
    } else {
        $TIME_ZONE = $args->{time_zone};
    }
}

sub get_time_zone {
    my $invocant = shift;
    ref $invocant ? $invocant->time_zone : $TIME_ZONE;
}

1;
__END__

=head1 NAME

DateTimeX::Factory - DateTime factory module with default timezone.

=head1 VERSION

This document describes DateTimeX::Factory version 0.03.

=head1 SYNOPSIS

    use DateTimeX::Factory;

    #Object interface
    my $factory = DateTimeX::Factory->new(
        time_zone => 'Asia/Tokyo',
    );
    my $now = $factory->now;

    #Class interface
    DateTimeX::Factory->set_time_zone(DateTime::TimeZone->new(name => 'Asia/Tokyo'));
    my $now = DateTimeX::Factory->now;

=head1 DESCRIPTION

DateTime factory module with default timezone.
This module include wrapper of default constructors and some useful methods.

=head1 METHODS

=head2 C<< set_time_zone($time_zone) >>

If called as instance method, set time_zone for its factory instance methods.
If called as class method, set time_zone for class methods.

    #Object interface
    {
        my $factory = DateTimeX::Factory->new();
        say $factory->now->time_zone->name; # floating

        $factory->set_time_zone(DateTime::TimeZone->new(name => 'Asia/Tokyo'));
        say $factory->now->time_zone->name; # Asia/Tokyo

        #This is also OK
        $factory->set_time_zone('Asia/Tokyo');
        say $factory->now->time_zone->name; # Asia/Tokyo

        # set to default time zone (floating)
        $factory->set_time_zone;
    }

    #Class interface
    {
        DateTimeX::Factory->set_time_zone(DateTime::TimeZone->new(name => 'Asia/Tokyo'));
        say DateTimeX::Factory->now->time_zone->name; #Asia/Tokyo

        #This is also OK
        DateTimeX::Factory->set_time_zone('Asia/Tokyo');
        say DateTimeX::Factory->now->time_zone->name; #Asia/Tokyo

        # set to default time zone (floating)
        DateTimeX::Factory->set_time_zone;
    }

=head2 C<< get_time_zone($time_zone) >>

Get DateTime::TimeZone instance of current time zone.

=head2 C<< create(%params) >>

Call DateTime->new with default parameter.

  my $datetime = DateTimeX::Factory->create(year => 2012, month => 1, day => 24, hour => 23, minute => 16, second => 5);

=head2 C<< now(%params) >>, C<< today(%params) >>, C<< from_epoch(%params) >>, C<< last_day_of_month(%params) >>, C<< from_day_of_year(%params) >>

See document of L<DateTime>.
But, these methods create DateTime instance by original method with default parameter.

=head2 C<< strptime($string, $pattern) >>

Parse string by DateTime::Format::Strptime with default parameter.

  my $datetime = DateTimeX::Factory->strptime('2012-01-24 23:16:05', '%Y-%m-%d %H:%M:%S');

=head2 C<< from_mysql_datetime($string) >>

Parse MySQL DATETIME string with default parameter.

  #equals my $datetime = DateTimeX::Factory->strptime('2012-01-24 23:16:05', '%Y-%m-%d %H:%M:%S');
  my $datetime = DateTimeX::Factory->from_mysql_datetime('2012-01-24 23:16:05');

=head2 C<< from_mysql_date($string) >>

Parse MySQL DATE string with default parameter.

  #equals my $date = DateTimeX::Factory->strptime('2012-01-24', '%Y-%m-%d');
  my $date = DateTimeX::Factory->from_mysql_date('2012-01-24');

=head2 C<< from_ymd($string, $delimiter) >>

Parse string like DateTime::ymd return value with default parameter.

  #equals my $date = DateTimeX::Factory->strptime('2012/01/24', '%Y/%m/%d');
  my $date = DateTimeX::Factory->from_ymd('2012-01-24', '/');

=head2 C<< tommorow(%params) >>

Create next day DateTime instance.

  #equals my $tommorow = DateTimeX::Factory->today->add(days => 1);
  my $tommorow = DateTimeX::Factory->tommorow;

=head2 C<< yesterday(%params) >>

Create previous day DateTime instance.

  #equals my $yesterday = DateTimeX::Factory->today->subtract(days => 1);
  my $yesterday = DateTimeX::Factory->yesterday;

=head1 DEPENDENCIES

Perl 5.10.0 or later.
L<Data::Validator>
L<DateTime>
L<DateTime::Format::MySQL>
L<DateTime::Format::Strptime>
L<DateTime::TimeZone>
L<Mouse>

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji@senchan.jpE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Nishibayashi Takuji. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
