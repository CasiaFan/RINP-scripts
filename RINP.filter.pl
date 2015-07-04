#!/usr/bin/perl -w
use strict;

#filter introns with no reads (RINP=0)
my ($infile, $outfile) = @ARGV[0,1];
die "Usage: perl $0 <RINP merge input file> <RINP filter output file>\neg: perl $0 wulijuan.RINP.out wulijuan.RINP.filter.out\n" unless @ARGV == 2;

my ($line, @list);
open IN, "$infile" or die "$!\n";
open OUT, "> $outfile" or die "$!\n";
while(<IN>){
	next if (/^\s*$/);
	chomp;
	$line = $_;
	if (/transcript_id/){print OUT "$line\n";next;}
	@list = split(/\s+/,$line);
#	my $threshold = 0.75*$list[3];
	if ($list[3] > 0 or $list[4] > 0 or $list[5] > 0){
		print OUT "$line\n";
	}
}
close IN;
close OUT;