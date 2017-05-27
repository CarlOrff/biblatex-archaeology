#!/usr/bin/perl

########################################################
#
# This script is part of the biblatex-archaeology
# package by Ingram Braun. It sole purpose is to
# build databases for string resolution from Excel
# files.
#
########################################################

use strict;
use utf8;
use feature 'unicode_strings';

use Spreadsheet::ParseExcel;
use Encode;
use FileHandle;
use Text::Unidecode;

my %titles;

# CTAN demands UNIX line feeds
my $newline = "\012";

my $linehight = '1.3ex';

my %strcount; # key = string, value = counter

# commands in bib file preamble
my %commands = (
    '\adddot' => ".",
    '\mkbibparens' => "(#1)",
    '\mkbibquote' => "``#1''",
);

#####################################
#          Parse Excel              #
#####################################

my $parser   = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse('abbreviation/RGK_Zeitschriften.xls');
 
if ( !defined $workbook ) {
    die "Module Spreadsheet::ParseExcel error: ".$parser->error(), ".\n";
}

for my $worksheet ( $workbook->worksheets() ) {

    my ( $row_min, $row_max ) = $worksheet->row_range();
 
    for my $row ( $row_min + 1 .. $row_max ) {
    
        my $js = $worksheet->get_cell( $row, 2 );
        
        # The DGUF xls file contains three worksheets of which two are empty.
        if ( defined $js && $js->can("value")) {
        
            my $key = clean_cell( $js->value() );
                
            if ( index( $key, 0 ) != 0 ) {
                
                print "Entry key '$key' not unique!" if exists( $titles{ $key } );
                    
                $titles{ $key }{ 'short' } =  clean_cell( $worksheet->get_cell( $row, 1 )->value() );
                $titles{ $key }{ 'string' } =  purify_string( $titles{ $key }{ 'short' } );
                
                # Check if shorthand is reused. This may happen if a title was slightly changed. If so, add colon and number.
                $titles{ $key }{ string } .= ":" . $strcount{ $titles{ $key }{ 'string' } } if ++$strcount{ $titles{ $key }{ 'string' } } > 1;
                             
                $titles{ $key }{ 'formatted_string' } = '\Stark{\texttt{' . ( $titles{ $key }{ 'string' } . '}}' );
                
                $titles{ $key }{ 'latexsort' } = latexsort( $key );
                
                # Split at first period, but do not match abbreviation dots (no quantifiers in lookbehinds allowed).
                # This is risky because dots may be included in arguments of LaTeX commands!
                ($titles{ $key }{ 'no_subtitles' }, my $subtitle) = split( /((?<=\p{Word}{4})|(?<=^\p{Word}{3})|(?<=\sLän))(\.|,? being)(?!\sSer)/, $key, 2 );
                $titles{ $key }{ 'no_subtitles' } = $key if $titles{ $key }{ 'no_subtitles' } =~ /Szab$/;
            }
            
        }
            
    }
}

# Check if titles without subtitles are unique. If not, restore full title
my %unique_titles;
grep { $unique_titles{ $titles{ $_ }{ 'no_subtitles' } }++ } keys %titles;
grep { $titles{ $_ }{ 'no_subtitles' } =  $_ if $unique_titles{ $titles{ $_ }{ 'no_subtitles' } } > 1 } keys %titles;

# Check if strings are unique. If not, abort.
my %unique_strings;
grep { $unique_strings{ $titles{ $_ }{ 'string' } }++ } keys %titles;
grep { die "String *$_* not unique" if $unique_titles{ $_ } > 1 } keys %unique_strings;

insert_driver( join( $newline, map { make_string( $titles{ $_ }{ 'string' }, $titles{ $_ }{ 'no_subtitles' } ) } sort stringsort keys %titles ), 'biblatex-archaeology-nodoc.dtx', 'fullBIB' );

insert_driver( join( $newline, map { make_string( $titles{ $_ }{ 'string' }, $_ ) } sort stringsort keys %titles ), 'biblatex-archaeology-nodoc.dtx', 'subtitlesBIB' );

insert_driver( join( $newline, map { make_string( $titles{ $_ }{ 'string' }, $titles{ $_ }{ 'short' } ) } sort stringsort keys %titles ), 'biblatex-archaeology-nodoc.dtx', 'rgkBIB' );

insert_file( join( "\\\\[$linehight]$newline", map { make_list( $_, $titles{ $_ }{ 'formatted_string' } ) } sort { $titles{ $a }{ 'latexsort' } cmp $titles{ $b }{ 'latexsort' } } keys %titles ), 'biblatex-archaeology.dtx', qr/(?<=\\subsection\{Sorted\sby\sjournal\sor\sseries\}\\label\{kap:journals\}.{3}).+?(?=.{5}\\section)/s );

insert_file( join( "\\\\[$linehight]$newline", map { make_list( $titles{ $_ }{ 'formatted_string' }, $_ ) } sort stringsort keys %titles ), 'biblatex-archaeology.dtx', qr/(?<=\\subsection\{Sorted\sby\sstring\}\\label\{kap:strings\}.{3}).+?(?=.{5}\\subsection)/s );

#####################################
#          Subroutines              #
#####################################

# Takes the short form as argument and purifies it so that it can be used as @STRING in BibTeX databases.
sub purify_string {

    my $string = shift;
    
    # remove LateX commands
    $string =~ s/\\[a-zA-Z]+\p{SpacePerl}*//g;
    
    # alternate conversion of German umlauts
    $string =~ s/ä/ae/g;
    $string =~ s/Ä/Ae/g;
    $string =~ s/ö/oe/g;
    $string =~ s/Ö/Oe/g;
    $string =~ s/ü/ue/g;
    $string =~ s/Ü/ue/g;
    
    # convert Unicode to ASCII
    unidecode($string);
    
    # remove all non-word characters
    $string =~ s/\W//g;
    
    # add namespace
    $string = "ufg-" . $string;
    
    $string;
}

# formats a @STRING for *.bib files with arg1 = arg2
sub make_string {

    my $string = shift;
    my $resolution = shift;
    
    # assure that trailing dots are not interpreted as periods.
    $string =~ s/\.$/\\adddot/;
    $resolution =~ s/\.$/\\adddot/;
    
    '@STRING{'. $string . ' = "' . $resolution . '"}';
}

# formats strings for list in dtx file
sub make_list {

    my $string = shift;
    my $resolution = shift;
        
    '% \StringBox{' . $string . '}{' . $resolution . '}';
}

# inserts arg1 into file arg2 as ltxdoc macrocode environment into driver arg3
sub insert_driver {

    my $bib = shift;
    my $dtx = shift;
    my $driver = shift;

    # generate macrocode environment of ltxdoc class
    my $env = "$newline%    \\begin{macrocode}$newline"; 
    $env .= $bib;
    $env .= "%    \\end{macrocode}$newline";

    my $source = "";
    my $out = FileHandle->new($dtx, O_RDONLY);
    if (defined $out) {
    
       binmode($out, ":utf8");

       while ( <$out> ) { $source .= $_ }
       
       $source =~ s/(<\*\Q$driver\E>).*?(<\/\Q$driver\E>)/\1$env%\2/s;
       undef $out;       # automatically closes the file
    }
    $out = FileHandle->new($dtx, O_WRONLY|O_TRUNC);
    if (defined $out) {
       
       print $out $source;
       
       undef $out;       # automatically closes the file
    }

}

# inserts arg1 into file arg2 were regexp arg3 matches
sub insert_file {

    my $text = shift;
    my $filename = shift;
    my $regexp = shift;
    my $file = '';
    
    my $fh = FileHandle->new( $filename, O_RDONLY );
    if ( defined $fh ) {
    
    binmode($fh, ":utf8");
        
        while (<$fh>) {$file .= $_;}
        undef $fh;
        
    }
    
    $file =~ s/$regexp/$text/;
    
    $fh = FileHandle->new( $filename, O_WRONLY|O_TRUNC );
    if ( defined $fh ) {
     
        print $fh $file;
        undef $fh;
        
    }
}

# correct spelling errors
sub clean_cell {

    my $string = shift;
    
    # OCR errors and typos
    $string =~ s/Null/Num/g;
    $string =~ s/Bibi/Bibl/g;
    $string =~ s/\(Königlich\)\s+//;
    $string =~ s/\(Preussischen\)\s+//;
    $string =~ s/(?<=Arch)öo/äo/gi;
    $string =~ s/^Aanteekeningen van het Verhandeide in de Sectie-Vergaderingen van het Provinciaal Utrechtsch Genootschap van Künsten en Wetenschappen.+$/Aanteekeningen van het Verhandelde in de Sectie-Vergaderingen van het Provinciaal Utrechtsch Genootschap van Künsten en Wetenschappen/g;
    $string =~ s/deJette et des A\.S\. B\.L\./de Jette et des A. S. B. L./g;
    $string =~ s/Cumania A /Cumania. A /g;
    $string =~ s/(?<=.)Helvetia Arch.+//g;
    $string =~ s/rqueologia da 2\. a /rqueologia da 2\.\\textsuperscript{a} /;
    $string =~ s/(?<=.)Athenaeum\. Studi.+//g;
    
    # trim
    $string =~ s/(^\p{SpacePerl}+|\p{SpacePerl}+$)//g;
    
    # capitalize first word
    $string = ucfirst $string;
    
    # LaTeX converts quotation marks to apostrophes
    $string =~ s/’/'/g;
    
    # convert tabs, linebreaks etc. into simple whitespaces and remove doubles
    $string =~ s/\p{SpacePerl}+/ /g;
    
    # remove wrong whitespace after divis
    $string =~ s/(\p{Word}-)\s(\p{Word})/\1\2/g;
    
    # dash instead of divis as indent
    $string =~ s/\s-\s/ -- /g;
    
    # thin space between abbreviation characters
    $string =~ s/(\b\p{Word}{1,2})\.\s(?=\p{Word}{1,2}\.)/\1.\\,/g;  
    
    # replace quotation marks
    $string =~ s/"(.+?)"/\\mkbibquote{\1}/g;
    $string =~ s/„(.+?)“/\\mkbibquote{\1}/g;
    $string =~ s/"(.+?)[«“]/\\mkbibquote{\1}/g;
    #$string =~ s/\xC2//g; # left from a phony quotation mark
        
    # replace parentheses
    $string =~ s/\((.+?)\)/\\mkbibparens{\1}/g;
    
    #$string = eval { decode( 'utf-8', $string, Encode::FB_CROAK ) } or die "Could not decode string: $@";
    
    $string;
}

sub latexsort {

    my $sort = shift;

    # remove LateX commands
    $sort =~ s/\\[a-zA-Z]+\p{SpacePerl}*//g;
    $sort =~ s/\\,/ /g;
    
    $sort = unidecode( $sort );
    
    # remove all non-word characters but save spaces
    my @split = split( /\s/, $sort );
    grep { $_ =~ s/\W//g } @split;
    $sort = join( " ", @split);
    
    lc $sort;
}

sub stringsort {

    lc $titles{ $a }{ 'string' } cmp lc $titles{ $b }{ 'string' };
}