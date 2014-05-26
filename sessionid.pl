#!/usr/bin/perl
my $length = shift @ARGV || 32;
my $char_set = ['0' .. '9', 'A' .. 'Z', 'a' .. 'z'];
my $session_id = join('', map {$char_set->[int(rand(62))]} (1 .. $length));

print $session_id, "\n";
