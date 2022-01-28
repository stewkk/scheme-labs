#!/usr/bin/env raku

sub memoize-function($function) {
    my %known-results;
    return -> |args {
        if %known-results{args}:exists {
            %known-results{args};
        } else {
            my $res = $function(|args);
            %known-results{args} = $res;
            $res;
        }
    }
}

sub test($a, $b) {
    say "computed";
    return $a + $b;
}

my $test-memo = memoize-function(&test);
say $test-memo(1, 2);
say $test-memo(1, 2);
say $test-memo(1, 3);
