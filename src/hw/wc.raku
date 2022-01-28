#!/usr/bin/env raku

sub get-stats($data, $name, $m, $c, $w, $l) {
    if !$m ?& !$c ?& !$w ?& !$l {
        print $data.lines.elems, " ", $data.words.elems, " ", $data.encode.bytes, " ";
    } else {
        if $l {
            print $data.lines.elems, " ";
        }
        if $w {
            print $data.words.elems, " ";
        }
        if $m {
            print $data.chars, " ";
        }
        if $c {
            print $data.encode.bytes, " ";
        }
    }
    if $name {
        say $name;
    } else {
        say "";
    }
}

sub MAIN(
    Bool :$m = False, #= print the character counts
    Bool :$c = False, #= print the byte counts
    Bool :$w = False, #= print the word counts
    Bool :$l = False, #= print the newline counts
    *@files
) {
    if !@files {
        get-stats(slurp(), "", $m, $c, $w, $l);
    }
    for @files -> $file {
        if $file.IO.r {
            get-stats($file.IO.slurp(), "$file", $m, $c, $w, $l);
        } else {
            note "can't read $file";
        }
    }
}
