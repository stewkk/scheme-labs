#!/usr/bin/env raku

sub gen-strings (Int $count, Int $len --> Array:D) {
    my Str @res;
    for 1..$count {
        my Str $pass ~= ('!' .. '~').pick() for 1..$len;
        @res.push($pass);
    }
    return @res;
}

sub MAIN(
    Int $length,
    Int $count
) {
    for gen-strings($count, $length) -> $str {
        say $str;
    }
}
