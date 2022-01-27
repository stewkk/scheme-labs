#!/usr/bin/env raku

sub match_files(@data, $file, $pattern, $e, $i, $n, $m, $is_single) {
    my $k = 1;
    for @data -> $line {
        my $res;
        if $e {
            if $i {
                $res = $line ~~ rx/:i $<result>=<$pattern>/;
            } else {
                $res = $line ~~ rx/$<result>=<$pattern>/;
            }
        } else {
            if $i {
                $res = $line.lower.contains($pattern.lower);
            } else {
                $res = $line.contains($pattern);
            }
        }
        if $res {
            unless $is_single {
                print $file.IO.path ~ ":";
            }
            if $n {
                say "$k:$line"
            } else {
                say $line;
            }
        }
        with $m {
            last if $m == $k;
        }
        $k += 1;
    }
}

sub MAIN(
    Str $pattern,
    Bool :$e, #= Enable regex search.
    Bool :$i, #= Ignore case distinctions in patterns and input data.
    Bool :$n, #= Output line numbers.
    Str :$m, #= Stop reading a file after NUM matching lines.
    *@path
) {
    given @path.elems {
        when 0 {
            my @data = slurp().lines;
            match_files(@data, "", $pattern, $e, $i, $n, $m, True);
        }
        when 1 {
            my $file = @path[0];
            unless $file.IO.r {
                note "error reading $file";
                return;
            }
            my @data = slurp($file).lines;
            match_files(@data, $file, $pattern, $e, $i, $n, $m, True);
        }
        default {
            for @path -> $file {
                unless $file.IO.r {
                    note "error reading $file";
                    return;
                }
                my @data = slurp($file).lines;
                match_files($file, @data, $pattern, $e, $i, $n, $m, False);
            }
        }
    }
}
