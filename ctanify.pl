#!/usr/bin/perl

########################################################
#
# This script is part of the biblatex-archaeology
# package [v2.0] by Ingram Braun. It sole purpose is to
# build a zip file for CTAN out of the development
# sources.
#
# https://www.ctan.org/help/upload-pkg
# https://www.ctan.org/help/pkg-readme
# https://www.ctan.org/help/markdown
#
# Remark that the script uses an unpublished bib file!
#
########################################################


use strict;
use utf8::all;
use warnings;

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Encode qw< decode >;
use FileHandle;
use File::Copy;
use File::Path qw(make_path remove_tree);
use File::Remove 'remove';
use Text::Markdown 'markdown';


####################
# GLOBAL VARIABLES #
####################

my $time = time;

# local date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;

system_call( "chcp 65001" ) if $^O eq 'MSWin32';

# pathes to local bib files
my @bib;
$bib[0] = $ENV{USERPROFILE}.'/Documents/ingram/Texte/bib/ingram.bib' if exists( $ENV{USERPROFILE} );

# package name
my $package = 'biblatex-archaeology';

# test file
my $expltex = "biblatex-archaeology_example.tex";

# CTAN demands UNIX line feeds
my $newline = "\012";

# log text
my $log;

# Create the CTAN archive
#add_log("Old chunk size: ".Archive::Zip::setChunkSize( 262144 ));
my $zip = Archive::Zip->new();

add_log("NEW RUN: $year-$mon-$mday $hour:$min:$sec");

###################
# CREATE ZIP FILE #
###################

# delete unzipped file
remove_tree( $package );

# add a root directory and name it $package
$zip->addDirectory( $package );

# add an example directory
my $expldir = "$package/example";
$zip->addDirectory( $expldir );

#generate databases
system_call( "lualatex -file-line-error $package.dtx" ); 
system_call( "lualatex -file-line-error $package" . "_example" );
system_call( "perl bibextract.pl $package $package-nodoc.dtx manualBIB " . join( " ", @bib ) );
system_call( "perl bibextract.pl biblatex-archaeology_example $package.dtx exampleBIB " . join( " ", @bib ) );
system_call( "perl abbrev.pl" ) if -e 'abbreviation/RGK_Zeitschriften.xls';
remove_intermediary_files();

# clean working directory
remove_intermediary_files();
remove( "*.bbx", "*.cbx", "*.dbx", "*.lbx", "*.sty", "*.bib", "$package.pdf" );

# install latest build
system_call("pdftex -8bit $package.ins");
system_call("texhash");

# generate manual
system_call( "lualatex -file-line-error $package.dtx" );
system_call( "biber $package" );
system_call( "perl datamodel.pl" );
system_call( "lualatex -file-line-error $package.dtx" );
system_call( "makeindex -s gind.ist $package.idx" );
system_call( "lualatex -file-line-error $package.dtx" );
system_call( "makeindex -s gglo.ist -o $package.gls $package.glo" );
system_call( "lualatex -file-line-error $package.dtx" );
system_call( "makeindex -s gglo.ist -o $package.gls $package.glo" );
system_call( "lualatex -file-line-error $package.dtx" );
system_call( "lualatex -file-line-error $package.dtx" );

# add sources
add_zip( "$package.dtx", $package );
add_zip( "$package-nodoc.dtx", $package );
add_zip( "$package.ins", $package );
add_zip( "$package.conf", $package );
my $markdown = add_zip( "README.md", $package );
add_zip( "$package.pdf", $package );
add_zip( $expltex, $expldir );

# We add a README.htm for optimized backlinks from CTAN mirrors
my $html = 'README.htm';
my $readmehtml = FileHandle->new($html, O_RDWR|O_TRUNC|O_CREAT);
if ( defined $readmehtml ) {
	$markdown =~ s/\bib_medium=readme\.md\b/'ib_medium='.lc($html)/egs;
	$markdown = markdown( $markdown, {
        empty_element_suffix => '>',
        tab_width => 5,
    } );
	
	finish( "Could not populate markdown file $html!" ) if length $markdown < 100;
	print $readmehtml '<!doctype html><html><meta charset="utf-8"></html><body>' . $markdown . '</body>';
	undef $readmehtml;      # automatically closes the file
	add_zip( $html, $package );
}
else { finish( "Could not open $html: $!" ) }

# generate example PDF for every style
opendir ( my $dh, "." ) or die $!;
my @styles = grep{ $_ = $1 if /(.+?)\.bbx$/ }readdir $dh;
closedir $dh;

my $eh = FileHandle->new($expltex, O_RDONLY);
my $example;
while( <$eh> ) { $example .= $_ }
undef $eh;       # automatically closes the file

foreach my $style ( @styles ) {

   $example =~ s/ingram-braun-local\.sty/this-file-does-not.exist/; # for test purposes: use package databases
    $example =~ s/\\usepackage((?:(?!\\usepackage).)*)\{biblatex\}/\\usepackage[style=$style]{biblatex}/s;
    my $jobname = $style . "-example";
    $eh = FileHandle->new( "$jobname.tex", O_WRONLY|O_CREAT );
    
    if ( defined $eh ) {
        
        print $eh $example;
        undef $eh;
        system_call( "lualatex -file-line-error $jobname" );
        system_call( "biber $jobname" );
        system_call( "lualatex -file-line-error $jobname" );
        system_call( "lualatex -file-line-error $jobname" );
        add_zip( "$jobname.pdf", $expldir );
    }
    else {
        finish("FATAL ERROR: Could not open $jobname.tex: $!");
    }
}

# Save the Zip file
my $fh = FileHandle->new( "$package.zip", O_WRONLY|O_TRUNC|O_CREAT );
if ( defined $fh ) {
    unless ( $zip->writeToFileHandle( $fh ) == AZ_OK ) {
       finish("FATAL ERROR: Could not store $package.zip: $!");
    }
}
else {
    finish("FATAL ERROR: Could not create $package.zip: $!");
}

remove_intermediary_files();
remove( '*-example.pdf' ); # deleting PDFs in the above loop destroys the archive!
    


###############
# EXIT SCRIPT #
###############

finish("Job regularly finished!");


###############
# SUBROUTINES #
###############

# append arguments to build log file
sub add_log {
	$log .= join('',(@_,$newline));
	print @_,"\n";
}

# adds a file (arg 1) to the archive member (arg 2) and converts CRLF to LF
sub add_zip {
	
    my $filename = shift;
    my $dir = shift;	
          
	add_log("Trying to open file ", $filename, "\n");
    if ($filename !~ /\.pdf$/) {

        my $handle = FileHandle->new($filename, O_RDONLY);
        
        if (defined $handle) {
            my $text;
			
            read( $handle, $text, -s $filename );
            undef $handle;       # automatically closes the file
			
			add_log("Number of characters: ", length $text, "\n");
			finish( "FATAL ERROR: empty file $filename" ) if length $text  < 1;
        
            # Ensure proper UTF-8 encoding and UNIX-like linebreaks.
            $text =~ s/\n/$newline/gs;
        
            my @lines = split( $newline, $text );
            add_log("Number of lines: ", scalar @lines, "\n");
			finish( "FATAL ERROR: no content to store in file '$filename'" ) if scalar @lines  < 1;
			
            foreach my $line (@lines) {
                my $line =
                    eval { decode( 'UTF-8', $line, Encode::FB_CROAK ) }
                    or finish("FATAL ERROR: Could not decode string $line: $@\n") if length $line > 0;
            }
            
            my $member = $zip->addString( $text, "$dir/$filename", COMPRESSION_LEVEL_BEST_COMPRESSION );
			
			# set UNIX file attributes on read-only
			$member->unixFileAttributes( 0644 ); # -rw-r--r--
			
            add_log("File $filename successfully added to ZIP archive.\n");
			return $text;
			
        }
        else {
            finish("FATAL ERROR: Could not open $filename: $!");
        }
		
	}
    else {

        my $member = $zip->addFile( $filename, "$dir/$filename", COMPRESSION_LEVEL_BEST_COMPRESSION );
        add_log("PDF file $filename successfully added to ZIP archive.\n");
		
		# set UNIX file attributes on read-only
		$member->unixFileAttributes( 0644 ); # -rw-r--r--
		
		return "";
    }
}

# remove intermediary files
sub remove_intermediary_files {
    
        my @files = (
            '4ct',
            '4tc',
            'aux',
            'bbl',
            'bcf',
            'blg',
            'css',
            'dvi',
            'glg',
            'glo',
            'gls',
            'hd',
            'html',
            'idv',
            'idx',
            'ilg',
            'ind',
            'lg',
            'lof',
            'log',
            'lot',
            'odt',
            'out',
            'run.xml',
            'tmp',
            'toc',
            'xdv',
            'xmpdata',
            'xmpi',
        );
        
    remove( join( ' *.', @files ) );
}

# save build log to file and exit script
sub finish {
	add_log($_[0]) if defined $_[0];
    
	my $logfh = FileHandle->new('ctanify.log', O_WRONLY|O_TRUNC|O_CREAT);
    
    my $exectime = (time - $time)/60;
    add_log("Script execution lasted $exectime minutes\n");
    
	if (defined $logfh) {
		print $logfh $log;
		die "\n$log";
	}
	else {die "FATAL ERROR: Could not write build log: $!"}
}

# call arg1 on command line and log result
sub system_call {

	add_log("EXEC: ".$_[0]);
	system($_[0]);
	
	if ($? == -1) {
		add_log("FATAL ERROR: failed to execute: $!\n");
	}
	elsif ($? & 127) {
		add_log(sprintf "child died with signal %d, %s coredump$newline", ($? & 127),  ($? & 128) ? 'with' : 'without');
	}
	else {
		add_log(sprintf "child exited with value %d\n", $? >> 8);
	}
}