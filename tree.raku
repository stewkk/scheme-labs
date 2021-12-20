#!/usr/bin/env raku

sub output-node(@prefix) {
    for @prefix -> $el {
        given $el {
            when 1 {
                print "├── ";
            }
            when 2 {
                print "└── ";
            }
            when 3 {
                print "│   ";
            }
            when 4 {
                print "    ";
            }
        }
    }
}

sub MAIN(
    Str $path = ".",
    Bool :$d = False,
    Str :$o
) {
    if $o.defined {
        my $output-file = open $o, :w;
        $*OUT = $output-file;
    }
    my $dirs = 0;
    my $files = 0;
    my @todo = [($path.IO, []),];
    while @todo {
        my $pair = @todo.pop;
        my $path = $pair[0];
        my @prefix = $pair[1];
        if @prefix {
            output-node(@prefix);
            print $path.basename;
            given $path {
                when .d {$dirs += 1};
                when .f {$files += 1};
            }
        } else {
            print $path;
        }
        if $path.d {
            try {
                for @prefix <-> $el {
                    given $el {
                        when 2 {$el = 4};
                        when 1 {$el = 3};
                    }
                }
                @prefix.push(1);
                my @contents = [($_, @prefix.clone)
                                for ($d
                                     ?? dir($path,
                                            test => { "$path/$_".IO.d ?& ! /^^ \./ })
                                     !! dir($path,
                                            test => { ! /^^ \./ })).sort(&lc)];
                if @contents {
                    @contents[*-1;1;*-1] = 2;
                }
                @contents.=reverse;
                @todo.append(@contents);
                CATCH {
                    default {
                        note " [error opening dir]";
                    }
                }
            }
        }
        say "";
    }
    if $d {
        say "$dirs directories";
    } else {
        say "$dirs directories, $files files";
    }
}
