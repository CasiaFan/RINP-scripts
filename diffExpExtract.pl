#!usr/bin/perl -w
use strict;

my ($geneInfo,$geneID,$extractOut) = @ARGV[0..2];

die "Usage: perl $0 <gene info file> <gene id file> <output extracted file>
eg: perl $0 N-4cell-1-C1-VS-N-8cell-1.GeneDiffExpFilter.xls 8C.gene.list 8C.gene
" unless @ARGV == 3; 

my ($line,@list);
my %INFO;

open INFO, "$geneInfo" or die "$!\n";
open UP, ">$extractOut.up" or die "$!\n";
open DOWN, " > $extractOut.down" or die "$!\n";
open UNC, "> $extractOut.nodiff" or die "$!\n";
while (<INFO>){
	chomp;
	$line = $_;
	@list = split(/\s+/,$line);
	if (/geneID/){print UP "$line\n";print DOWN "$line\n";print UNC "$line\n";};
	$INFO{$list[0]} = $line;
}
close INFO;

open ID, "$geneID" or die "$!\n";
my ($countUp,$countDown,$countUnc) =(0,0,0);
open STAT, "> $extractOut.stat" or die "$!\n";
while (<ID>){
	chomp;
	my $id = $_;
	if(exists $INFO{$id}){
		if($INFO{$id} =~ /Up/){print UP "$INFO{$id}\n";$countUp++;}
		if($INFO{$id} =~ /Down/){print DOWN "$INFO{$id}\n";$countDown++;}
	}else{
		print UNC "$id\n";
		$countUnc++;
	}
}
print STAT "Up\tDown\tUnchanged\n";
print STAT "$countUp\t$countDown\t$countUnc\n";
close ID;
close UP;
close DOWN;
close UNC;
close STAT;