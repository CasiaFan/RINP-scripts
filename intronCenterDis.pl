#!/usr/bin/perl -w
use strict;

my ($intronStart,$intronLoc,$intronDisRef) = @ARGV[0..2];
die "This script is to get the file that contains the distance from each intron center to the gene's start codon
Usage: perl $0 <intron start bed file> <intron location ref bed file> <intron distance file> 
eg: perl $0 hg19-refGene.bed hg19_intron_annotation.bed hg19_intron_centerDistance.out 
" unless @ARGV == 3;

my ($line,@list,%INTRON,%GENELEN,$len,$id,@start,@exonlen,$dis,$start);
open INST, "$intronStart" or die "$!\n";
while(<INST>){
	chomp;
	$line = $_;
	@list = split(/\s+/,$line);
	@exonlen = split(/,/,$list[10]);
	@start = split(/,/,$list[11]);
	$len = @start;
	next if($len == 1);
	my $n = 0;
	while($len>$n){
		if($n<($len-1)){
			my $i = $n+1;
			$dis = ($start[$i]+$exonlen[$n]+$start[$n])/2;
		}else{
			$dis = ($list[2]-$list[1]+$start[$n]+$exonlen[$n])/2;
		}
		$start = $list[1]+$exonlen[$n]+$start[$n];
		$id = "$list[3]_$list[0]_$start";
		$GENELEN{$id} = $list[2]-$list[1];
		$INTRON{$id} = $dis;
		$n ++;
	}
}
close INST;

open INLOC, "$intronLoc" or die "$!\n";
open OUT, "> $intronDisRef" or die "$!\n";
my ($gene);
while (<INLOC>){
	chomp;
	$line = $_;
	@list = split(/\s+/,$line);
	if($list[3] =~ /(.+)_intron_.+/){$gene = "$1_$list[0]_$list[1]";}
	print OUT "$list[3]\t$INTRON{$gene}\t$GENELEN{$gene}\n";
}
close INLOC;
close OUT;


