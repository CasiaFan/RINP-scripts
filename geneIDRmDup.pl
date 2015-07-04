#!/usr/bin/perl -w 
use strict;

my ($total_gene_file,$outnodup) = @ARGV[0,1];

die "Usage: perl $0 <merged gene id file> <total gene id output without duplication>
eg: perl $0 C8.gene.merged C8.gene
" unless @ARGV == 2;

my ($line, @list);
my %GENE;

open IN, "$total_gene_file" or die "$!\n";
open OUT, "> $outnodup" or die "$!\n";
my $count =0;
while(<IN>){
	chomp;
	next if(/geneID/);
	$line = $_;
	@list = split(/\s+/,$line);
	unless(exists $GENE{$list[0]}){
		print OUT "$list[0]\n";
		$count ++;
	}	
	$GENE{$list[0]} = 1;
}
#	my $n = keys %GENE;
#	print $n;
#print $count;
close IN;
close OUT;