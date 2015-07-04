#!/usr/bin/perl -w
use strict;

my ($RINP_merge, $cutoff, $outdir) = @ARGV[0..2];

die "Usage: perl $0 <RINP merge input file> <RINP bg noise> <EGA sh script file output dir>
eg: perl $0 /ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/embNP/SL-wulijuan.RINP.merge 0.0122 EGA
" unless @ARGV == 3;

my ($line,@list);
open IN, "$RINP_merge" or die "$!\n";
open SH, "> $outdir/RINP-EGA.sh" or die "$!\n";

if($outdir eq "."){
	$outdir = `pwd`;
}else{
	my $curwd = `pwd`;
	$curwd =~ s/\n//;
	$outdir = "$curwd/$outdir";
	`mkdir $outdir` unless (-d $outdir);
}

my $bin = "$outdir/bin";
my $ega = "$outdir/EGA";
`mkdir $bin` unless (-d $bin);
`mkdir $ega` unless (-d $ega);
 
 my $getGeneIDScript = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/embPro/pattern3_IntronicRegion/transcript2geneid.pl";
 
 my %sampleID;
 my ($precol,$curcol,$sample);
 while (<IN>){
	chomp;
	$line = $_;
	@list = split(/\s+/,$line);
	if(/transcript_id/){
		my $len = @list;
		my $i = 4;
		while($i < $len){
			if($list[$i] =~ /(\w+)-.*RINP/){
				$sample = $1;
			}
			my $outsh = $list[$i];
			$outsh =~ s/-RINP/-RINP-EGA\.sh/;
			my $outega = $list[$i];
			$outega =~ s/-RINP/-RINP\.EGA\.out/;
			open OUT, "> $bin/$outsh" or die "$!\n";
			$curcol = $i+1;
			unless(exists $sampleID{$sample}){ 
				$precol = $i;
			}
			$sampleID{$sample} = 1;
			print OUT "awk '{if(\$$curcol>$cutoff && \$$curcol > 10*\$$precol)print \$0}' $RINP_merge > $ega/$outega\n";
			print OUT "perl $getGeneIDScript $ega/$outega $ega/$list[$i].gene\n";
			print SH "sh $bin/$outsh\n";
			$i ++;
			close OUT;
		}
		close SH;
	}
	 last;
 }
 close IN;