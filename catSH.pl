#!/usr/bin/perl -w
use strict;

my ($rawdataList, $outdir) = @ARGV[0,1];
die "Usage: cat splited pe data--perl $0 <rawdata Dir list> <ouput dir>\neg:perl $0 sample.list .\n" unless @ARGV == 2;

my @dataList;
my $i =0;
open DIR, "$rawdataList" or die "$!\n";
while (<DIR>){
	chomp;
	next unless(defined);
	$dataList[$i] = $_;
	$i++;
}
close DIR;

open SH, "> cat.sh" or die "$!\n";
print SH "echo Start Time:;date\n";
my $n = 1;
foreach my $indir (@dataList){
	print SH "gunzip -c $indir/*_1.fq.gz.clean.dup.clean.gz | cat - > $outdir/1-$n.temp &\n";
	print SH "gunzip -c $indir/*_2.fq.gz.clean.dup.clean.gz | cat - > $outdir/2-$n.temp &\n";
	$n++;
}
print SH "	
	if($? -eq 0);then
		cat 1-*.temp > parthenogeneticPig_pe1.unformated.temp
		cat 2-*.temp > parthenogeneticPig_pe2.unformated.temp 
	fi
";
print SH "perl format.pl parthenogeneticPig_pe1.unformated.temp parthenogeneticPig_pe1.fastq\n";
print SH "perl format.pl parthenogeneticPig_pe2.unformated.temp parthenogeneticPig_pe2.fastq\n";
print SH "rm *.temp\n";
print SH "echo End Time:;date\n";