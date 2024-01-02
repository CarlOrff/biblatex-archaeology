#!/usr/bin/perl

########################################################
#
# This script is part of the biblatex-archaeology
# package by Ingram Braun. Its purpose is to
# build a full set of example files for various
# output formats
#
########################################################

use strict;
use feature 'say';

use File::Copy qw( mv );
use File::Remove 'remove';
use FileHandle;

# fetch sample file
my $expltex = 'biblatex-archaeology_example.tex';
my $source;
my $eh = FileHandle->new($expltex, O_RDONLY);
while( <$eh> ) { $source .= $_ }
undef $eh;       # automatically closes the file

# rename files to stop latexmk
rename 'biblatex-archaeology_example.tex', 'biblatex-archaeology_example.te_';
rename 'biblatex-archaeology_intro_de.tex', 'biblatex-archaeology_intro_de.te_';


# make a list of styles
my @style;
opendir ( my $dh, "." ) or die $!;
while (my $codefile = readdir $dh) {
    
	push( @style, $1 ) if $codefile =~ /(.+?)\.bbx$/;
}
closedir $dh;

my %format = ( 
	'pdf' => 'pdf',
	'html5' => 'html',
	'xhtml' => 'html',
	'odt' => 'odt',
	'epub' => 'epub',
	'tei' => 'xml',
	'docbook' => 'xml',
);

my @engine = (
	'pdflatex',
	'lualatex',
	'xelatex',
);

my ( %latex, $jobname );
$latex{ pdf }{ lualatex } = "latexmk -quiet -time -lualatex -pdf $jobname";
$latex{ pdf }{ pdflatex } = "latexmk -quiet -time -pdflatex -pdf $jobname";
$latex{ pdf }{ xelatex } = "latexmk -quiet -time -xelatex -pdf $jobname";
$latex{ epub }{ lualatex } = "tex4ebook -e mycfg.mk4 -l $jobname.tex";
$latex{ epub }{ pdflatex } = "tex4ebook -e mycfg.mk4 $jobname.tex";
$latex{ epub }{ xelatex } = "tex4ebook -e mycfg.mk4 -x $jobname.tex";
$latex{ html5 }{ lualatex } = "make4ht -e mycfg.mk4 -l -f html5 $jobname.tex \"fn-in\"";
$latex{ html5 }{ pdflatex } = "make4ht -e mycfg.mk4 -f html5 $jobname.tex \"fn-in\"";
$latex{ html5 }{ xelatex } = "make4ht -e mycfg.mk4 -x -f html5 $jobname.tex \"fn-in\"";
$latex{ xhtml }{ lualatex } = "make4ht -e mycfg.mk4 -l -f xhtml $jobname.tex \"fn-in\"";
$latex{ xhtml }{ pdflatex } = "make4ht -e mycfg.mk4 -f xhtml $jobname.tex \"fn-in\"";
$latex{ xhtml }{ xelatex } = "make4ht -e mycfg.mk4 -x -f xhtml $jobname.tex \"fn-in\"";
$latex{ odt }{ lualatex } = "make4ht -e mycfg.mk4 -l -f odt $jobname.tex";
$latex{ odt }{ pdflatex } = "make4ht -e mycfg.mk4 -f odt $jobname.tex";
$latex{ odt }{ xelatex } = "make4ht -e mycfg.mk4 -x -f odt $jobname.tex";
$latex{ tei }{ lualatex } = "make4ht -e mycfg.mk4 -l -f tei $jobname.tex";
$latex{ tei }{ pdflatex } = "make4ht -e mycfg.mk4 -f tei $jobname.tex";
$latex{ tei }{ xelatex } = "make4ht -e mycfg.mk4 -x -f tei $jobname.tex";
$latex{ docbook }{ lualatex } = "make4ht -e mycfg.mk4 -l -f docbook $jobname.tex";
$latex{ docbook }{ pdflatex } = "make4ht -e mycfg.mk4 -f docbook $jobname.tex";
$latex{ docbook }{ xelatex } = "make4ht -e mycfg.mk4 -x -f docbook $jobname.tex";


system( 'latexmk -C' );

foreach my $style ( @style ) {
	
	$source =~ s/\\usepackage((?:(?!\\usepackage).)*)\{biblatex\}/\\usepackage[style=$style]{biblatex}/s;
	$jobname = $style . "-example";
    $eh = FileHandle->new( "$jobname.tex", O_WRONLY|O_CREAT );
	print $eh $source;
	undef $eh;
	
	
	foreach my $format ( keys %format ) {
		
		foreach my $engine ( @engine ) {
			
			if ( exists( $latex{ $format }{ $engine } ) ) {
				
				system( $latex{ $format }{ $engine } ) if $format eq "pdf" && $engine eq "pdflatex";
				mv( "$jobname.$format{ $format }", "testsuite/$style-$format-$engine.$format{ $format }" )
			}
			else { say "No command found for format $format and engine $engine!"; }	
		}
	}
	
	remove( "$jobname.*" );
}

# rename excluded files
rename 'biblatex-archaeology_example.te_', 'biblatex-archaeology_example.tex';
rename 'biblatex-archaeology_intro_de.te_', 'biblatex-archaeology_intro_de.tex';