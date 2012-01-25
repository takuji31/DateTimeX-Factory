use strict;
use Test::LoadAllModules;
use Test::More;

BEGIN {
    all_uses_ok(
        search_path => "DateTimeX::Factory",
        except => [],
    );
}


diag "Testing DateTimeX::Factory/$DateTimeX::Factory::VERSION";
