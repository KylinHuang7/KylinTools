#!/usr/bin/perl
use strict;
use WebBrowser;
use Encode;
use Data::Dump;

my $browser = WebBrowser->new();
$browser->visit('http://192.168.1.201:9001');
print Data::Dump::dump($browser), "\n";


