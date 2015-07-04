#!/usr/bin/perl -w
use strict;

my ($bedtool_coverage,$htseq_count,$outfile) = @ARGV[0,1,2];

die "Usage: perl $0 <bedtool coverage output> <htseq intron reads count file> <output file>\n \
e.g: perl $0 coverage.count intron_htseq.count RINP.cal.out\n" unless @ARGV == 3;

my (@list,$line);

open COV, "$bedtool_coverage" or die "$!\n";
my %ID;
while (<COV>){
	chomp;
	$line = $_;
	@list = split(/\s+/,$line);
	my $transcript_id = $list[3];
	my $strand = $list[5];
	my $total_align_reads = $list[6];
	my $intron_length = $list[8];
	my $uncovered_reads = $list[7];
	$ID{$transcript_id} = "$transcript_id\t$strand\t$total_align_reads\t$intron_length\t$uncovered_reads";	
}
close COV;

open COUNT, "$htseq_count" or die "$!\n";
while(<COUNT>){
	chomp;
	$line = $_;
	@list = split(/\s+/,$line);
	my $id = $list[0];
	my $complete_intron_align_reads = $list[1];
	if(exists $ID{$id}){
		$ID{$id} .= "\t$complete_intron_align_reads";
	}#else{
#		$ID{$id} = "$id\t*\t*\t*\t*\t$complete_intron_align_reads";
#	}
}
close COUNT;

open OUT, "> $outfile" or die "$!\n";
print OUT "transcript_id\tstrand\ttotal_intron_aligned_reads\tintron_length\tuncovered_reads\tcomplete_intron_aligned_reads\tRINP\t";
print OUT "(if uncovered_reads are none, set it as 1)\n";

foreach my $iter (keys %ID){
	my @items = split(/\s+/,$ID{$iter});
	if(@items == 5){$items[5]=0}
	if(($items[4] eq '*') or ($items[4] == 0)){
		$items[4]=1;
	}
	
	my $RINP = $items[5]/$items[4];
	print OUT "$ID{$iter}\t$RINP\n";
}
close OUT;
