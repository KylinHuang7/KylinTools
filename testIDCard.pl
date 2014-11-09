#!/usr/bin/perl
use strict;
use IDCard;

my $test = [
IDCard->new('11010519491231002X'),
IDCard->new('440524188001010014'),
IDCard->new(''),
IDCard->new('1398721312312'),
IDCard->new('1938081918390213A1'),
IDCard->new('33010684-414003'),
IDCard->new('330106840414003'),
IDCard->new('111111111111111'),
IDCard->new('111111111111111111'),
IDCard->new('123456780912345'),
IDCard->new('123456780912345678'),
];

foreach my $card (@$test) {
    output($card);
}

sub output {
    my $t = shift;
    if (defined($t)) {
        print $t->type(), "\t", $t->id_card(), "\t", $t->gender(), "\t", $t->birthday(), "\n";
    } else {
        print "Wrong\n";
    }
}
