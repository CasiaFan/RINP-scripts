#!/usr/bin/perl -w
use strict;

my ($configInput, $outdir) = @ARGV[0,1];
die "Usage: perl $0 <soap & soapsnp input config> <output dir>
eg: perl $0 pathernogenetic-pig.config pathernogenetic-pig
" unless @ARGV == 2;

#software path:
my 