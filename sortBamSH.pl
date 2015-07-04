#!/usr/bin/perl -w
use strict;

my($sampleList,$type,$outdir) = @ARGV[0,1,2];

die "Usage:perl $0 <sample list file> <sort type> <outputDir>\neg:perl $0 C2.list pos/name/all sorted\n" unless @ARGV == 3;
`mkdir $outdir` unless (-d $outdir);

open FI, "$sampleList" or die "$!\n";
my %sampleList;
my @lists;
while(<FI>){
	chomp;
	next unless(defined);
	next if(/\#/);
	@lists = split(/\s*=\s*/,$_);
	$sampleList{$lists[0]} = $lists[1];
}

my $samtools = "/share/backup/fanzong/software/samtools-0.1.19/samtools";
open SH, "> sortedBam.sh" or die "$!\n";
print SH "echo Start Time:;date\n";
foreach my $iter (keys %sampleList){
	if($type eq "pos" or $type eq "all"){
		print SH "samtools sort $sampleList{$iter} $outdir/$iter.pos.sorted &\n";
	}
	if($type eq "name" or $type eq "all"){
		print SH "samtools sort -n $sampleList{$iter} $outdir/$iter.name.sorted &\n";
	}
}
print SH "echo End Time:;date\n";
close SH;