#!/usr/bin/perl

########################################################
#
# This script is part of the biblatex-archaeology
# package by Ingram Braun. It sole purpose is to
# build a extract the XML datamodel from a *.bcf file
# and provide it for insertion into biber.conf.
#
########################################################

use strict;
use utf8::all;

use FileHandle;
use XML::Twig;

my $dtx = 'biblatex-archaeology.dtx';

# Load only datamodel group from *.bcf file and remove prefix.

my $t= XML::Twig->new(
	twig_roots => { 'bcf:datamodel' => 1 },
	twig_handlers => { _all_ => sub
						{my $tag= $_->tag; $tag=~ s{^[^:]*:}{}; $_->set_tag( $tag);},
					 });
$t->parsefile( 'biblatex-archaeology.bcf');
$t->set_pretty_print('indented');
my $datamodel = $t->sprint;

# remove the controlfile element that XML::TWIG adds as root element and prepare prepare *.dtx insertion
$datamodel =~ s/<\?xml\sversion=.+?\?>/%    \\begin{macrocode}/s;
$datamodel =~ s/<controlfile.*?>/<!-- REPLACE THE <DATAMODEL> GROUP IN THE BIBER *.CONF FILE WITH THE GROUP BELOW -->/;
$datamodel =~ s/<\/controlfile>/%    \\end{macrocode}/;

# copy data model into dtx file

my $source;
my $out = FileHandle->new($dtx, O_RDONLY);
if (defined $out) {

   while ( <$out> ) { $source .= $_ }
   
   $source =~ s/(<\*BiberCONF>\n%\s?\\fi\n).*?(\n%\s?\iffalse\n<\/BiberCONF>)/\1\n$datamodel%\2/s;
   undef $out;       # automatically closes the file
}
$out = FileHandle->new($dtx, O_WRONLY|O_TRUNC);
if (defined $out) {
   
   print $out $source;
   
   undef $out;       # automatically closes the file
}
