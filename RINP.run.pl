#!/usr/bin/perl -w
use strict;
use File::Basename;
#from bowtie alignment to htseq and bedtools

my ($inCov,$inCount,$outDir,$sampleName,$refbed,$refgtf) = @ARGV[0..5];

die "Usage: perl $0 <inputFile for Coverage> <iutputFile for htseq> <RINP output dir> <sampleName> <bed refFile for coverage> 
<gtf ref file for readsCount>\neg:perl $0 pos.sorted.reads.bam name.sorted.reads.bam RINP.out MII Sscrofa10.2_intron_anno.sorted.bed 
Sscrofa10.2_intron_anno.sorted.gtf\n" unless @ARGV == 6;

`mkdir $outDir` unless(-d $outDir);
#output total SH file
open SH, "> $outDir/$sampleName.sh" or die "$!\n";
print SH "echo Start Time:;date\n";

my $sufflix = ".bam";
my $base_inCov = basename($inCov,$sufflix);
my $base_inCount = basename($inCount,$sufflix);
#my $outDir = dirname($outfile);
my $bin = "$outDir/bin";
my $RINP = "$outDir/RINP";
`mkdir $bin` unless (-d $bin);
`mkdir $RINP`unless (-d $RINP);

#sort files
my $samtools = "/share/backup/fanzong/software/samtools-0.1.19/samtools";
#print SH "$samtools view -b $inCov | $samtools sort -of - deltheme > $base_inCov.posSorted.bam\n";
#print SH "$samtools view -b $inCount | $samtools sort -nof - deltheme > $base_inCount.nameSorted.bam\n";
unless ($refbed =~ /sorted/){
	print SH "sort -k1,1 -k2,2n $refbed > $refbed.sorted.bed\n" ;
	$refbed = "$refbed.sorted.bed";
}


#output coverage.sh file
my $bedtools = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/embPro/software/bedtools2-master/bin/bedtools";
open COV, "> $outDir/bin/intron.$base_inCov.coverage.sh" or die "$!\n";
print COV "$bedtools coverage -sorted -a $refbed -b $inCov > RINP/$base_inCov.coverage\n";
close COV;
print SH "sh bin/intron.$base_inCov.coverage.sh\n";

#output count.sh file
my $htseq = "/share/backup/fanzong/software/python-2.7.8/bin/htseq-count";
open COUNT, "> $outDir/bin/intron.$base_inCount.count.sh" or die "$!\n";
print COUNT "$samtools view $inCount | htseq-count -r name -m intersection-strict - $refgtf > RINP/$base_inCount.count\n";
close COUNT;
print SH "sh bin/intron.$base_inCount.count.sh\n";

#calculate the RINP
my $RINPcal = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/embPro/pattern3_IntronicRegion/RINPcal.pl";
print SH "perl $RINPcal RINP/$base_inCov.coverage RINP/$base_inCount.count $sampleName.RINP.out\n";

#my $sample_suffix = ".name.sorted.bam";
#my @samples = glob ''

print SH "echo End Time:;date\n";
close SH;