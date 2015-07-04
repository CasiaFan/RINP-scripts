#!/usr/bin/perl -w
use strict;

my ($rinpMerge, $cutoff, $outdir) = @ARGV[0..2];
die "Usage: perl $0 <sample RINP merge file> <background RINP noise> <ouput directory>
eg: perl $0 SL-wulijuan.RINP.merge 0.0122 .
note: 1. take notice ofd sample merge file rank order and number
2. the bg noise is determined by the 75th percentile of MII genes whose RINP > 0
" unless @ARGV == 3;

my ($line,@list);
my @outfiles;
my %col;
my $EGAIntronDisScript = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/embPro/pattern3_IntronicRegion/EGA_gene_intronDis_extract.pl";
my $intronDisRef = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/hg19_intron_ref/hg19_intron_centerDistance.out";

#mkdir for output;
if($outdir eq "."){
	$outdir = `pwd`;
	$outdir =~ s/\n//;
}else{
	my $curwd = `pwd`;
	$curwd =~ s/\n//;
	$outdir = $curwd."/$outdir";
	`mkdir $outdir` unless (-d $outdir);
}
my $bin = "$outdir/bin";
my $intronDis = "$outdir/intronDis";
`mkdir $bin` unless (-d $bin);
`mkdir $intronDis` unless (-d $intronDis);

open IN, "$rinpMerge" or die "$!\n";
open SH, "> $outdir/RINP-intronDis.sh" or die "$!\n";
while (<IN>){
	chomp;
	$line = $_;
	@list = split(/\s+/,$line);
	my $fileNum = @list-3;
	my $pointer = 0;
	if(/transcript_id/){
		while($pointer<$fileNum){
			my $curcol = $pointer+3;
			$outfiles[$pointer] = "$list[$curcol]\_filter.sh";
			$col{$outfiles[$pointer]} = $curcol;
			$pointer++;
		}
	}
	
	foreach my $outfile (@outfiles){
		open OUT, "> $bin/$outfile" or die "$!\n";
		my $filterout = $outfile;
		$filterout =~ s/_filter\.sh/\.filter/;
		my $intronDisout = $outfile;
		$intronDisout =~ s/_filter\.sh/\.intronDis.out/;
		my $awkcol = $col{$outfile}+1;
		print OUT "awk '{if(\$$awkcol>$cutoff)print \$0}' $rinpMerge > $intronDis/$filterout\n";
		print OUT "perl $EGAIntronDisScript $intronDis/$filterout $intronDisRef $intronDis/$intronDisout\n";		
		close OUT;
		print SH  "sh $bin/$outfile\n";
	}
	last;
}
close SH;