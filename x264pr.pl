#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use IO::Handle;

my %opts;
my $VERSION = "0.3";
getopts('huro:q:x:b:', \%opts);

if ($opts{'h'}) {
	HELP_MESSAGE();
	exit 1;
}

my $infile = shift @ARGV;
if (!$infile) {
	print("Usage: x264pr.pl [options] infile\n");
	exit 1;
}

my $outfile	    = $opts{'o'} ? $opts{'o'} : "${infile}.mkv";
my $qp  	    = $opts{'q'} ? $opts{'q'} : 0;
my $x264options = $opts{'x'} ? $opts{'x'} : 0;
my $batch       = $opts{'b'} ? $opts{'b'} : "${infile}.bat";
my $unlink      = $opts{'u'} ? $opts{'u'} : 0;
my $run         = $opts{'r'} ? $opts{'r'} : 0;

open my $x264, "< $x264options" or die "Cannot read template: $!";

open my $encode, "> $batch" or die "Cannot write encoding batch file: $!";

my @cmd;
push(@cmd,"#!/bin/sh\n");

while(<$x264>)
{
   while (/(.+)/g) {
      push(@cmd, $1);
   }
}

if ($qp) {
   push(@cmd,"--qpfile","\"$qp\"")
}

push(@cmd,"--output","\"$outfile\"","\"$infile\"");
{
print $encode join(' ',@cmd,"\n");
}
close $x264;
close $encode;
if ($run) {
   chmod 0755, $batch;
   system("./${batch}");
}
if ($unlink) {
   unlink $batch;
}

exit 0;
sub HELP_MESSAGE {
	print <<EOF;
$0 $VERSION By PharaohAnubis
Usage: x264pr.pl [options] infile
Where infile is the video to encode. Thanks to RiCON for the fixes.

Options:

-o OUTFILE
    The filename of the final encode.

-x X264OPTIONS
    The text file where the options are for the encode.

-b BATCH
    BATCH file to run the encode.

-r
    Execute BATCH.

-u
    Remove BATCH after execution.
EOF
}

