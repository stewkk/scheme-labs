#!/usr/bin/env raku

grammar G {
    token TOP { [<separator> <word> <separator>]* }
    token punctuation { <+:punct -[']>* }
    token separator { <.ws> <punctuation> <.ws> }
    token word { ["'" | \w]+ }
}

multi MAIN(
    Str $dictionary where *.IO.f,
    Str $text where *.IO.f
) {
    my @dict = $dictionary.IO.lines;
    my $i = 0;
    for $text.IO.lines -> $line {
        my $match = G.parse($line);
        for $/<word> -> $word {
            my $str-word = $word.Str;
            if !($str-word (elem) @dict) {
                say $i, " ", $word.pos, " ", $str-word;
            }
        }
        $i += 1;
    }
}

multi MAIN(
    Str $text where *.IO.f,
    Bool :$c
) {
    my $output-file = open "dict", :w;
    $*OUT = $output-file;
    my $match = G.parse($text.IO.slurp);
    for [$_.Str for $/<word>] -> $word {
        say $word;
    }
}
