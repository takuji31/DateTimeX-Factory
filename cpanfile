requires 'Data::Validator', '0.05';
requires 'DateTime';
requires 'DateTime::Format::MySQL';
requires 'DateTime::Format::Strptime';
requires 'DateTime::TimeZone';
requires 'Mouse';

on build => sub {
    requires 'Test::LoadAllModules', '0.02';
    requires 'Test::More', '0.96';
};
