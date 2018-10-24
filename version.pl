#!/usr/bin/perl

########################################################
#
# This script is part of the biblatex-archaeology
# package by Ingram Braun. It sole purpose is to
# mark biblatex-archaeology documentation files with
# version and date.
#
# https://www.ctan.org/help/upload-pkg
# https://www.ctan.org/help/pkg-readme
# https://www.ctan.org/help/markdown
#
########################################################

use strict;

use Carp::Assert;
use FileHandle;
use utf8::all;
use feature 'say';

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year += 1900;
$mon++;
$mon = '0' . $mon if $mon <= 9; # trailing zero
my $date = $year . '/' . $mon . '/' . $mday;

my $version = 'v2.1';
assert( $version =~ /v\d\.\d{1,3}[a-z]?/ );

my @files = qw/
	biblatex-archaeology.dtx
	README.md
	biblatex-archaeology_example.tex
/;

grep { version_file( $_ ) } @files;


sub version_file {

	my $file = shift;
	
	
	assert( $version =~ /v\d\.\d{1,2}[a-z]?/ );
	
	my $text = '';
	
	my $fh = FileHandle->new($file, O_RDONLY);
    
	if (defined $fh) {
	
		read( $fh, $text, -s $file);
		undef $fh;
	}
	else {die "Could not open $file: $!"}
	
	my $bak = $text;
	
	$text =~ s/(biblatex-archaeology`?(\spackage|\sstyles)?\s\[)v\d\.\d{1,3}[a-z]?(\])/$1$version$3/gs;
	$text =~ s/\[\d{4}\/\d{2}\/\d{2}\sv\d\.\d{1,3}[a-z]?\sbiblatex-archaeology/'[' . $date . ' ' . $version . ' biblatex-archaeology'/egs;
	$text =~ s/(archbib\sstyles\s\[)v\d\.\d{1,3}[a-z]?(\])/$1$version$2/gs;
	$text =~ s/(biblatex-archaeology-)v\d\.\d{1,3}[a-z]?/$1$version/g;
	
	
	if ($text ne $bak) {
	
		$fh = FileHandle->new($file, O_WRONLY|O_TRUNC);
		if (defined $fh) {
		
			print $fh $text;
			undef $fh;
		}
		else {die "Could not open $file: $!"}
	}
	else {
		say "$file not changed!";
	}
}