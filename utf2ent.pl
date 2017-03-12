#!/usr/bin/perl

##################################################################
#
# converts non-US-ASCII characters to \entity{[charnum]}
#
# author: C. V. Radhakrishnan
# source: http://comments.gmane.org/gmane.comp.tex.tex4ht/591
#
# you have to define \entity in your document:
#
#	\makeatletter
#	\def\hshchr{\expandafter\@gobble\string\#}
#	\def\ampchr{\expandafter\@gobble\string\&}
#	\def\entity#1{\HCode{\ampchr\hshchr#1;}}
#	\makeatother
#
##################################################################

use strict;
use warnings;

for my $file ( @ARGV ){
  open my $fh, '<:utf8', $file or die "cannot open file $file: $!";
   while( <$fh> ){
      s/([\x7f-\x{ffffff}])/'\\entity{'.ord($1).'}'/ge;
        print;
  }
}

