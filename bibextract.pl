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
use BibTex::Parser;
use Data::Dumper;

my $project = shift @ARGV;
$project .= ".aux";
my $outbib = shift @ARGV;
my @inbib = @ARGV;

my %db;      # entries of outfile
my %buffer;  # other entries, needed for crossref check

# get keys from aux.file
my $aux = FileHandle->new("< $project");

if (defined $aux) {

    print "READ $project\n";

    while(<$aux>) { $db{$1}{count}++ if $_ =~ /\\abx\@aux\@cite\{(.+?)\}/; }
    undef $aux;       # automatically closes the file
}
else { die "Could not open $project: $1" }

# read databases
foreach my $inbib (@inbib) {

    print "READ $inbib\n";

    my $fh = FileHandle->new("< $inbib");
     
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

my $bib = FileHandle->new($outbib, O_WRONLY|O_TRUNC|O_CREAT);

if (defined $bib) {

    print "WRITE $outbib\n";
    
    grep { print $bib $db{$_}{entry}, "\n" if $db{$_}{type} =~ /^article|^in|^supp/i } sort keys %db;
    grep { print $bib $db{$_}{entry}, "\n" if $db{$_}{type} !~ /^article|^in|^supp/i } sort keys %db;
    
    undef $bib;       # automatically closes the file
}
else { die "Could not open $outbib: $1" }

