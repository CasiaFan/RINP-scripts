#!/usr/bin/perl -w
use strict;
use File::Basename;

my (@files) = @ARGV;

die "Usage: perl $0 <RINP file 1> <RINP file 2> ... <output merge file>\ne.g:perl $0 MII.RINP.out 2PN.RINP.out wulijuan.RINP.out\n" unless @ARGV >= 3;

my $file_counts = @files;
my @input_files = @files;
my $outfile = pop @input_files;

my (%transcript_info,%RINP_info);
my ($line,@list);
foreach my $in (@input_files){
	open IN, "$in" or die "$!\n";
	while (<IN>){
		next if (/^\s*$/ or /transcript_id/);
		chomp;
		$line = $_;
		@list = split(/\s+/,$line);
		my $info = "$list[0]\t$list[1]\t$list[3]\t";
		unless(exists $transcript_info{$list[0]}){$transcript_info{$list[0]} = $info;}
		my $sampleRINP = "$list[0]\_$in";
#		if(defined $list[6]){
		$RINP_info{$sampleRINP} = $list[6];
#		}else{
#			$RINP_info{$sampleRINP} = 0;
#		}
	}
	close IN;
}

open TITLE, "> header" or die "$!\n";
print TITLE "transcript_id\tstrand\tintron_length\t";
foreach my $i (@input_files){
	my $rinp_title = basename $i;
	$rinp_title =~ s/\.RINP\.out//;
	print TITLE	"$rinp_title-RINP\t";
}
print TITLE "\n";
close TITLE;

open OUT, "> RINP.temp" or die "$!\n";
foreach my $symbol (keys %transcript_info){
	print OUT "$transcript_info{$symbol}\t";
	foreach my $ot (@input_files){
		my $sampleRINP = "$symbol\_$ot";
		unless (defined $RINP_info{$sampleRINP}){$RINP_info{$sampleRINP} =0;} #in case some ref transcripts unshown in specific sample
		print OUT "$RINP_info{$sampleRINP}\t";
	}
	print OUT "\n";
}
close OUT;

`sort -k1,1 RINP.temp > RINP.sorted.temp`;
`cat header RINP.sorted.temp > $outfile`;
`rm header RINP.temp RINP.sorted.temp`;
