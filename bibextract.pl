#!/usr/bin/perl

########################################################
#
# This script is part of the biblatex-archaeology
# package by Ingram Braun. It sole purpose is to
# extract publishable databases from the author's
# private (and unpublished) bib file.
#
# call: see bibtex.bat
#
########################################################

use strict;
no warnings;

use FileHandle;
use BibTeX::Parser;
#use Data::Dumper;

my $project = shift @ARGV;
$project .= ".aux";
my $dtx = shift @ARGV;
my $driver = shift @ARGV;
my @inbib = @ARGV;

my %db;      # entries of outfile
my %buffer;  # other entries, needed for crossref check

# CTAN demands UNIX line feeds
my $newline = "\012";

# get keys from aux.file
my $aux = FileHandle->new("< $project");

if (defined $aux) {

    binmode($aux, ":utf8");

    print "READ $project\n";

    while(<$aux>) { $db{$3}{count}++ if $_ =~ /\\abx\@aux\@(cite|segm)(\{\d+\})*\{(.+?)\}/; }
    undef $aux;       # automatically closes the file
}
else { die "Could not open $project: $1" }

# read databases
foreach my $inbib (@inbib) {

    print "READ $inbib\n";

    my $fh = FileHandle->new("< $inbib");
    
    binmode($fh, ":utf8");
     
    # Create parser object ...
    my $parser = BibTeX::Parser->new($fh);
    my $entry;
     
    # ... and iterate over entries
    while ( $entry = $parser->next ) {
    
        my %entries;

        if ( $entry->parse_ok ) {
        
            $entries{$entry->key}{entry} = $entry->field("_raw");
            $entries{$entry->key}{type} = $entry->type;
            push( @{$entries{$entry->key}{crossref}}, $entry->field("crossref") );
            push( @{$entries{$entry->key}{crossref}}, $entry->field("xref") );
            push( @{$entries{$entry->key}{crossref}}, split( /,\s*/, $entry->field("entryset") ) );
            push( @{$entries{$entry->key}{crossref}}, split( /,\s*/, $entry->field("related") ) );
            push( @{$entries{$entry->key}{crossref}}, split( /,\s*/, $entry->field("xdata") ) );
            
            if ( exists( $db{ $entry->key } ) ) {
                $db{ $entry->key } = $entries{ $entry->key };
            }
            else {
                $buffer{ $entry->key } = $entries{ $entry->key };
            }
        }
        else {
            die "Error parsing file: " . $entry->error;
        }
    }
    $fh->close();
}

# crossref check
my $found = 1;

unless ( !$found ) {

    undef $found;
    
    foreach my $selected ( keys %db ) {
    
        foreach my $crossref ( @{$db{$selected}{crossref}} ) {

            if ( length $crossref > 0 && !exists( $db{$crossref} ) ) {
            
                if ( !exists( $buffer{$crossref} ) ) {
                    warn "Referenced key '$crossref' does not exist in database!\n";
                }
                else {
                    $found = 1;
                    $db{$crossref} = $buffer{$crossref};
                }
            }
        }
    }
}

# generate macrocode environment of ltxdoc class
my $bib = "$newline%    \\begin{macrocode}$newline"; 
grep { $bib .= $db{$_}{entry} . "$newline" if $db{$_}{type} =~ /^article|^in|^supp|^review/i } sort keys %db;
grep { $bib .= $db{$_}{entry} . "$newline" if $db{$_}{type} !~ /^article|^in|^supp|^review/i } sort keys %db;
$bib .= "%    \\end{macrocode}$newline";
$bib =~ s/\n\s+(\w+)\s?=/$newline  \U\1\E =/gs;
$bib =~ s/\n/$newline/gs;


# copy database into dtx file
my $source = "";
my $out = FileHandle->new($dtx, O_RDONLY);
if (defined $out) {

   binmode($out, ":utf8");

   while ( <$out> ) { $source .= $_ }
   
   $source =~ s/(<\*\Q$driver\E>\n%\s?\\fi\n).*?(\n%\s\\iffalse\n%<\/\Q$driver\E>)/\1$bib%\2/s;
   undef $out;       # automatically closes the file
   print "\nPATTERN: ", $&. "\n\n";
}
$out = FileHandle->new($dtx, O_WRONLY|O_TRUNC);
if (defined $out) {

   binmode($out, ":utf8");
   
   print $out $source;
   
   undef $out;       # automatically closes the file
}

    

