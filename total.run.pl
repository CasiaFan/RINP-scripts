#!/usr/bin/perl -w
use strict;
use File::Basename;

my ($configure,$outdir,$outsh) = @ARGV[0,1,2];

die "Usage:perl $0 <input_configure file> <output dir> <total output sh file>\ne.g: perl $0 RINP_input.config . total.run.sh\n" unless @ARGV == 3;

#software path
my $samtools = "/share/backup/fanzong/software/samtools-0.1.19/samtools";
my $bedtools = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/embPro/software/bedtools2-master/bin/bedtools";
my $htseq = "/share/backup/fanzong/software/python-2.7.8/bin/htseq-count";
my $RINPcal = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/embPro/pattern3_IntronicRegion/RINPcal.pl";
my $mergeRINP = "/ifs1/ST_RM/PMO/F14ZQSQSSY1574/fanzong/embPro/pattern3_IntronicRegion/RINP.merge.pl";;

my ($line,@list,%input);

#output total run sh 
open IT, "$configure" or die "$!\n";
open SH, "> $outsh" or die "$!\n";
print SH "echo start time:;date\n";

while (<IT>){
	next if (/^\n/);
	chomp;
	next if(/:/);
	$line = $_;
	@list = split(/\s*=\s*/,$line);
	$input{$list[0]} = $list[1];
}
close IT;

#make dir based on sample names
if($outdir eq "."){
	$outdir = `pwd`;
	$outdir =~ s/\n//;
}else{
	my $curwd = `pwd`;
	$curwd =~ s/\n//;
	$outdir = $curwd."/$outdir";
	`mkdir $outdir` unless (-d $outdir);
}

my %outDirList;
foreach my $intbam(keys %input){
	if($intbam =~ /(\w+-\w+)-(.+)/){
		my $sampleName = $1;
		my $sampleStage = $2;
		
		#make dir
		my $sorted_dataDir = "$outdir/$sampleName/sorted_data";
		my $sampleNameDir = "$outdir/$sampleName";
		my $binDir = "$outdir/$sampleName/bin";
		my $RINPDir = "$outdir/$sampleName/RINP";
		`mkdir $sampleNameDir` unless (-d $sampleNameDir);
		`mkdir $sorted_dataDir` unless (-d $sorted_dataDir);
		`mkdir $binDir` unless (-d $binDir);
		`mkdir $RINPDir` unless (-d $RINPDir);
		unless(exists $outDirList{$sampleName}){$outDirList{$sampleName} = $sampleNameDir;}
		#output sample run sh 
		open OT, "> $outdir/$sampleName/$intbam.sh" or die "$!\n";
		print OT "echo Make Directories done!\n";
		
		#output sort sample bam sh
		print OT "echo Sort bam files Start Time:;date\n";
		open SORT, "> $sorted_dataDir/$intbam-sortedBam.sh" or die "$!\n";
		print SORT "echo Start Time:;date\n";
		if($input{sort_type} eq "pos" or $input{sort_type} eq "all"){
	#		print SORT "samtools sort $input{$intbam} $sorted_dataDir/$intbam.pos.sorted\n";
			print SORT "$bedtools bamtobed -split -i $input{$intbam} | sort -k1,1 -k2,2n - > $sorted_dataDir/$intbam.pos.sorted.bed\n";
		}
		if($input{sort_type} eq "name" or $input{sort_type} eq "all"){
			print SORT "#samtools sort -n $input{$intbam} $sorted_dataDir/$intbam.name.sorted\n";
		}
		print SORT "echo samtools sort $input{$intbam} done!\n";
		print SORT "echo End Time:;date\n";
		close SORT;
		print OT "sh $sorted_dataDir/$intbam-sortedBam.sh\n";
		#print OT "qsub -cwd -q st.q -P st_rm -l vf=1G $sorted_dataDir/$intbam-sortedBam.sh\n";
		print OT "echo samtools sort completed!\n";
		print OT "echo sort bam file done at:;date\n";
		
		#output bedtools coverage sh 
		my $refbed = $input{intron_referrence_bed_file};
		unless ($refbed =~ /sorted/){
			print OT "sort -k1,1 -k2,2n $refbed > $refbed.sorted.bed\n" ;
			$refbed = "$input{intron_referrence_bed_file}.sorted.bed";
		}
		open COV, "> $outdir/$sampleName/bin/$intbam.intron.coverage.sh" or die "$!\n";
		print COV "$bedtools coverage -sorted -a $refbed -b $sorted_dataDir/$intbam.pos.sorted.bed -s > $RINPDir/$sampleStage.intron.coverage\n";
		close COV;
		print OT "echo bedtools calculates intron coverage start at:;date\n";
		print OT "sh $binDir/$intbam.intron.coverage.sh\n";
	#	print OT "qsub -cwd -q st.q -P st_rm -l vf=3G $binDir/$intbam.intron.coverage.sh\n";
	#	print OT "sleep 15m\n";
		print OT "echo $intbam intron coverage calculation done!\n";
		print OT "echo bedtools calculates intron coverage end at:;date\n";
		
		#output htseq count sh 
		open COUNT, "> $outdir/$sampleName/bin/$intbam.intron.count.sh" or die "$!\n";
		print COUNT "$samtools view $sorted_dataDir/$intbam.name.sorted.bam | htseq-count -r name -m intersection-strict -s - $input{intron_referrence_gtf_file} > $RINPDir/$sampleStage.intron.count\n";
		close COUNT;
		print OT "echo htseq calculates the intron completely aligned reads counts start at:;date\n";
		print OT "sh $binDir/$intbam.intron.count.sh\n";
		print OT "echo $intbam intron reads count done!\n";
		print OT "echo htseq calculates the intron completely aigned reads counts end at:;date\n";
		
		#calculate the sample RINP
		print OT "echo sample RINP calculation starts at:;date\n";
		print OT "perl $RINPcal $RINPDir/$sampleStage.intron.coverage $RINPDir/$sampleStage.intron.count $RINPDir/$sampleStage.RINP.out\n";
		print OT "echo $intbam RINP calculation done!\n";
		print OT "echo sample RINP calculation ends at:;date\n";
		
		#output sample total sh 
		print SH "echo sample $intbam RINP calculation starts at:;date\n";
		print SH "sh $outdir/$sampleName/$intbam.sh &\n";
#		print SH "qsub -cwd -q st.q -P st_rm -l vf=3G $outdir/$sampleName/$intbam.sh\n";
		print SH "echo $intbam RINP calculation completed!\n";
		print SH "echo sample $intbam RINP calculation ends at:;date\n";

	}
	close OT;	
	
}

foreach my $rinp_dir (keys %outDirList){
	my @files = glob "$outDirList{$rinp_dir}/RINP/*.RINP.out";
	my $mergeout = basename $outDirList{$rinp_dir};
	open MERGE, "> $outDirList{$rinp_dir}/RINP/mergeRINP.sh" or die "$!\n";
	print SH "echo merge RINP files in dir $outDirList{$rinp_dir}/RINP starts at:;date\n";
	print MERGE "perl $mergeRINP ";
	foreach my $rinp_file (@files){
		print MERGE "$rinp_file ";
	}
	print MERGE "$outDirList{$rinp_dir}/RINP/$mergeout.RINP.merge\n";
	print MERGE "awk '{print \$1,\$2,\$3,\$10,\$4,\$5,\$6,\$7,\$8,\$9}' $outDirList{$rinp_dir}/RINP/$mergeout.RINP.merge > $outDirList{$rinp_dir}/RINP/$mergeout.RINP.merge.sorted\n";
	print MERGE "mv $outDirList{$rinp_dir}/RINP/$mergeout.RINP.merge.sorted $outDirList{$rinp_dir}/RINP/$mergeout.RINP.merge\n";
	close MERGE;
	print SH "sh $outDirList{$rinp_dir}/RINP/mergeRINP.sh\n";
	print SH "echo merge RINP files in dir $outDirList{$rinp_dir}/RINP ends at:;date\n";
}

print SH "echo End time:;date\n";
close SH;