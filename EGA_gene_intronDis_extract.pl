#!/usr/bin/perl -w
use strict;

my ($EGAFile,$intronDisFile,$EGAIntronDisFile) = @ARGV[0..2]; 
die "This Script is to extract the data from EGA file for ploting intronDis versus transcript length
Usage: perl $0 <EGA file> <intron center distance file> <EGA intron center distance file>
eg:perl $0 2PN-EGA-10fold.out /ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/hg19_intron_ref/hg19_intron_centerDistance.out 2PN-EGA-intronDis.out
" unless @ARGV == 3;

my ($line,@list);
my (%INTRON);
open REF, "$intronDisFile" or die "$!\n";
while(<REF>){
	chomp;
	$line = $_;
	@list = split(/\s+/,$line);
	my $info = "$list[1]\t$list[2]";
	$INTRON{$list[0]} = $info;
}
close REF;

open IN, "$EGAFile" or die "$!\n";
open OUT, "> $EGAIntronDisFile" or die "$!\n";
while(<IN>){
	chomp;
	$line = $_;
	next if (/transcript_id/);
	@list = split(/\s+/,$line);
	print OUT "$list[0]\t$INTRON{$list[0]}\n";
}
close IN;
close OUT;
