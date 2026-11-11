# Day 2 interview questions: Perl basics

1. **What do `use strict` and `use warnings` do?**
   `strict` forces variable declaration (`my`), forbids symbolic references and barewords, catching typos
   at compile time. `warnings` reports suspicious runtime things such as using `undef` or `"abc" + 1`.

2. **Difference between `==` and `eq`?**
   `==` compares numbers, `eq` compares strings. `"1.0" == "1"` is true, `"1.0" eq "1"` is false.

3. **What is context in Perl?**
   Expressions behave differently in scalar vs list context. `my $n = @a;` gives the element count,
   `my ($first) = @a;` gives the first element. `localtime` returns a string in scalar context and a list in list context.

4. **What is `$_`?**
   The default variable: used by `for`, `map`, `grep`, `while (<$fh>)`, and by many functions (`print`, `chomp`, regex match) when no argument is given.

5. **How do you make a 2D data structure?**
   With references: `my %by_show = (news => [ {ep=>1}, {ep=>2} ]);` then `$by_show{news}[1]{ep}`.

6. **What does `my ($x) = $str =~ /(\d+)/;` do, and why the parentheses around `$x`?**
   The match in list context returns the captures; `($x)` takes the first. Without parentheses
   (scalar context) `$x` would get 1/"" (did it match?), not the number.

7. **Three-argument `open` vs two-argument `open`: why prefer three?**
   `open my $fh, '<', $path` treats `$path` purely as a filename. Two-arg `open(FH, $path)` interprets
   characters like `>` or `|` in the name, which is a security hole with user input.

8. **How would you sort a hash by value, descending?**
   `sort { $h{$b} <=> $h{$a} } keys %h`. Add `|| $a cmp $b` for a stable tie-break.

9. **What is `$!` vs `$@`?**
   `$!` is the OS error (errno text) after a failed system call; `$@` is the error from the last `eval`.

10. **Why is Perl still used in media/ops teams?**
    Excellent text processing and regex, available on every Linux box, huge CPAN library, quick to
    glue command-line tools together, and lots of existing production code.
