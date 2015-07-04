#!/usr/bin/perl -w
use strict;

my ($infile,$outfile) = @ARGV[0,1];

die "Usage: perl $0 <EGA transcript file in> <EGA gene file out>\neg:perl $0 2PN-EGA-10fold.out 2PN-EGA-gene.out\n" unless @ARGV == 2;

my $ref = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/hg19_intron_ref/refMrna.fa.gene2mark";
#my $ref = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/hg19_intron_ref/hg19_refGene.txt";
open REF, "$ref" or die "$!\n";
my ($line,@list);
my %id;
while(<REF>){
	chomp;
#	next if(/^\s*$/);
	$line = $_;
	@list = split(/\s+/,$line);
	$id{$list[1]} = $list[0]; 
#	$id{$list[1]} = $list[12];
}
close REF;

open IN, "$infile" or die "$!\n";
open OUT, "> $outfile" or die "$!\n";
my $transcript_count = 0;
my $gene_count = 0;
my %transcript;
my $transcript_id;
while(<IN>){
	chomp;
	$line = $_;
	if(/transcript_id/){print OUT "geneID\t$line\n";next;}
	@list = split(/\s+/,$line);
	if($list[0] =~ /(\w+_\d+)_intron_.+/){$transcript_id = $1;}
	unless(exists $id{$transcript_id}){$id{$transcript_id} = "$transcript_id";}
	print OUT "$id{$transcript_id}\t$line\n";
	$transcript_count ++;
	my $geneid = $id{$transcript_id};
	unless(exists $transcript{$geneid}){$gene_count++;}
	$transcript{$geneid} = 1;
}
close IN;
close OUT;

my $statfile = "$outfile.stat";
open STAT, "> $statfile" or die "$!\n";
print STAT "total_EGA_transctripts\ttotal_EGA_genes\n";
print STAT "$transcript_count\t$gene_count\n";
close STAT;