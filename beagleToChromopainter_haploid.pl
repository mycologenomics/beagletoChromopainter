#!/usr/bin/perl
## CONVERTS PHASE (CHROMOPAINTER) FORMAT TO BEAGLE FORMAT
use strict;
use warnings;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

sub help {
print("EXTRACT\n");

print("usage:   perl beagleToChromopainter.pl <bglfile> <outphasefile> <donorfile>\n");

print("where:\n");

print("<options>:\n");
print("-v: Verbose mode\n");
die "\n";
}

####################################
## Functions we need
sub trim($){  # remove whitespace from beginning and end of the argument
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

###############################
## ARGUMENT PROCESSING

my $infile="";
my $outfile="";
my $donorfile="";
my $verbose=0;

GetOptions ('v|verbose' => \$verbose);
if(@ARGV != 3) {help();}

$infile=$ARGV[0];
$outfile=$ARGV[1];
$donorfile=$ARGV[2];

####################################
## 
my @fulldata;
my $nsnps=0;
my $nhaps=0;
my @snplocs;

## Check we can read the input files
open INFILE, $infile or die $!;
my $tmp=<INFILE>;
$tmp=trim($tmp);
my @header = split(/\s+/, $tmp);
splice (@header,0,2);
$nhaps= scalar(@header);

##

open OUTFILE, ">", $outfile or die $!;
open DONORFILE, ">", $donorfile or die $!;

for(my $i=0;$i<scalar(@header);++$i){
    print DONORFILE "$header[$i]\n";
}
close DONORFILE;

# remaining lines are SNPs
while (my $tmp=<INFILE>) {
    $tmp=trim($tmp);
    my @tarr=split(/\s+/,$tmp);
    push @snplocs,$tarr[1];
    splice (@tarr,0,2);

    push @fulldata, [ @tarr ];
    ++$nsnps;
} 

print OUTFILE "0\n$nhaps\n$nsnps\nP ";
for(my $j=0;$j<$nsnps-1;++$j){
    print OUTFILE "$snplocs[$j] ";
}
print OUTFILE "$snplocs[$nsnps-1]\n";
for(my $j=0;$j<$nsnps;++$j){
    print OUTFILE "S";
}
print OUTFILE "\n";

for(my $i=0;$i<$nhaps;++$i){
    for(my $j=0;$j<$nsnps;++$j){
	print OUTFILE "$fulldata[$j][$i]";
    }
    print OUTFILE "\n";
}
close OUTFILE;
