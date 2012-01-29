use strict;
use warnings;
use Module::Build;

my $buiild = Module::Build->new(
    dist_author => 'takuji@senchan.jp <takuji@senchan.jp>',
    dist_abstract => 'DateTimeX-Factory',
    license     => 'perl',
    module_name => 'DateTimeX::Factory',
    configure_requires => {'Module::Build' => '0.38'},
    requires => {
        'Data::Validator'            => '0.05',
        'DateTime'                   => 0,
        'DateTime::TimeZone'         => 0,
        'DateTime::Format::MySQL'    => 0,
        'DateTime::Format::Strptime' => 0,
        'Mouse'                      => 0,
    },
    build_requires => {
        'Test::LoadAllModules'       => '0.02',
        'Test::More'                 => '0.96',
    },
    test_files => (-d '.git/' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,

    create_readme => 1,
    create_license => 1,
    create_makefile_pl => 'small',
);
$buiild->create_build_script();
