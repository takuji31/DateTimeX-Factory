use strict;
use Test::LoadAllModules;

BEGIN {
    all_uses_ok(
        search_path => "DateTime::Factory",
        except => [],
    );
}


diag "Testing DateTime::Factory/$DateTime::Factory::VERSION";
