#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use POSIX qw(floor);
use IO::Handle;

my %opts;
my $VERSION = "0.21";
getopts('h:o:q:x:b:i:', \%opts);

if ($opts{'h'}) {
	HELP_MESSAGE();
	exit 1;
}

my $infile = shift @ARGV;
if (!$infile) {
	print("Usage: x264pr.pl [options] infile");
	exit 1;
}

my $outfile	= $opts{'o'} ? $opts{'o'} : "${infile}.mkv";
my $qp  	= $opts{'q'} ? $opts{'q'} : 0;
my $x264options = $opts{'x'} ? $opts{'x'} : 0;
my $batch       = $opts{'b'} ? $opts{'b'} : 0;

open my $x264, "< $x264options" or die "Cannot read template: $!";

open my $encode, "> $batch" or die "Cannot write encoding batch file: $!";

while(<$x264>)
{
   print $encode $_;
}
{
printf $encode " --qpfile \"$qp\" --output \"$outfile\" \"$infile\" "
}
close $x264;
close $encode;
{
system("$batch");
unlink $batch;
}
exit 0;
sub HELP_MESSAGE {
	print <<EOF;
$0 $VERSION By PharaohAnubis
Usage: x264pr.pl [options] infile
Where infile is the video to encode. It does remove automatically your .bat file after encoding.

Options:
-i INFILE
    The avisynth script to encode.

-o OUTFILE
    The filename of the final encode.

-x X264OPTIONS
    The .txt file where the options are for the encode.

-b BATCH
    The .bat file to run the encode.
EOF
}

