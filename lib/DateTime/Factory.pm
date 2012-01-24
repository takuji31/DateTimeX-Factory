package DateTime::Factory;
use 5.010_000;
use strict;
use warnings;

our $VERSION = '0.01';

use Data::Validator;
use DateTime;
use DateTime::TimeZone;

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

our @METHODS = (
    [new => 'create'],
    qw/
        from_epoch
        now
        today
        from_object
        last_day_of_month
        from_day_of_year
    /,
);

{
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
        delimiter => {isa => 'Str'},
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
    return wantarray ? %options : {%options};
}

1;
__END__

=head1 NAME

DateTime::Factory - Perl extention to do something

=head1 VERSION

This document describes DateTime::Factory version 0.01.

=head1 SYNOPSIS

    use DateTime::Factory;

    my $factory = DateTime::Factory->new(
        time_zone => 'Asia/Tokyo',
    );

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.10.0 or later.

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
