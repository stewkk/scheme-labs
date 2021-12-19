#!/usr/bin/env raku

sub MAIN(
    Str $path?,
    Str $pattern = "",
    Str :$e,
    Bool :$i,
    Bool :$n,
    Int :$m
) {
    my @data;
    with $path {
        with $path.IO.r {
            @data = slurp($path).lines;
        } else {
            note "error reading $path";
            return;
        }
    } else {
        @data = slurp().lines;
    }
    my $regex;
    with $e {
        $regex = $e;
    } else {
        $regex = $pattern;
    }
    my $k = 1;
    for @data -> $line {
        if $i {
            $line ~~ rx/:i $<result>=<$regex>/;
        } else {
            $line ~~ rx/$<result>=<$regex>/;
        }
        if $<result> {
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
