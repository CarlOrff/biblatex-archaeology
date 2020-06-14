#!/usr/bin/perl

########################################################
#
# This script is part of the biblatex-archaeology
# package by Ingram Braun. It sole purpose is to
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
use File::Find;
use File::Path qw(make_path remove_tree);
use File::Remove 'remove';
use Text::Markdown 'markdown';


####################
# GLOBAL VARIABLES #
####################

my $time = time;


my $DEBUG = 0; # 0 if production, 1 if debug mode

# local date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;


# CTAN demands UNIX line feeds
my $newline = "\012";

system_call( "chcp 65001" ) if $^O eq 'MSWin32';

# pathes to local bib files
my @bib;
$bib[0] = $ENV{USERPROFILE}.'/Documents/ingram/Texte/bib/ingram.bib' if exists( $ENV{USERPROFILE} );

# package name
my $package = 'biblatex-archaeology';

# TDS file name
my $tds_filename = $package.'.tds.zip';

# test file
my $expltex = "biblatex-archaeology_example.tex";

# log text
my $log;

# Create the CTAN archive
#add_log("Old chunk size: ".Archive::Zip::setChunkSize( 262144 ));
my $zip = Archive::Zip->new();

add_log("NEW RUN: $year-$mon-$mday $hour:$min:$sec");

###################
# CREATE ZIP FILE #
###################

# delete old files
remove_tree( $package );
remove_tree( "$package.tds" );
remove_intermediary_files();
remove( '*-example.pdf' ); # deleting PDFs in the above loop destroys the archive!
remove( '*.zip' );

# add a root directory and name it $package
$zip->addDirectory( $package );

# add an example directory
my $expldir = "$package/example";
$zip->addDirectory( $expldir );

#############################
# CREATE TDS COMPLIANT FILE #
#############################

my $tds = Archive::Zip->new();

# add a root directories
my $tds_tex = "tex/latex/$package";
$tds->addDirectory( $tds_tex );
my $tds_doc = "doc/latex/$package";
$tds->addDirectory( $tds_doc );
my $tds_expl = "$tds_doc/example";
$tds->addDirectory( $tds_expl );
my $tds_bib = "bibtex/bib/$package";
$tds->addDirectory( $tds_bib );
my $tds_source = "source/latex/$package";
$tds->addDirectory( $tds_source );

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
if ( !$DEBUG ) {
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
}

# add sources
add_zip( 0, "$package.dtx", $package );
add_zip( 0, "$package-nodoc.dtx", $package );
add_zip( 0, "$package.ins", $package );
add_zip( 0, "$package.conf", $package );
my $markdown = add_zip( 0, "README.md", $package );
add_zip( 0, "$package.pdf", $package ) if !$DEBUG;
add_zip( 0, $expltex, $expldir );

# add sources to TDS
add_zip( 1, "$package.dtx", $tds_source );
add_zip( 1, "$package-nodoc.dtx", $tds_source );
add_zip( 1, "$package.ins", $tds_source );
add_zip( 1, "$package.conf", $tds_doc );
add_zip( 1, "README.md", $tds_doc );
add_zip( 1, "$package.pdf", $tds_doc ) if !$DEBUG;
add_zip( 1, $expltex, $tds_expl );

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
	add_zip( 0, $html, $package );
	add_zip( 1, $html, $tds_doc );
}
else { finish( "Could not open $html: $!" ) }

my ( @codefiles, @bibliographies, @styles);
opendir ( my $dh, "." ) or die $!;
while (my $codefile = readdir $dh) {
    
	push( @styles, $1 ) if $codefile =~ /(.+?)\.bbx$/;
	push( @bibliographies, $& )  if $codefile =~ /.+?\.bib$/;
	push( @codefiles, $& )  if $codefile =~ /.+?\.([bcdl]bx|sty)$/;
}
closedir $dh;

# add package files to TDS
grep { add_zip( 1, $_, $tds_bib ) } @bibliographies;
grep { add_zip( 1, $_, $tds_tex ) } @codefiles;

my $eh = FileHandle->new($expltex, O_RDONLY);
my $example;
while( <$eh> ) { $example .= $_ }
undef $eh;       # automatically closes the file

# generate example PDF for every style
foreach my $style ( @styles ) {

    #$example =~ s/ingram-braun-local\.sty/this-file-does-not.exist/; # for test purposes: use package databases
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
        add_zip( 0, "$jobname.pdf", $expldir );
		add_zip( 1, "$jobname.pdf", $tds_expl );
    }
    else {
        finish("FATAL ERROR: Could not open $jobname.tex: $!");
    }
	
	last if $DEBUG; # shorten execution time in debug mode;
}

find(\&handle_file);

# Save the TDS file
my $fh = FileHandle->new( $tds_filename, O_WRONLY|O_TRUNC|O_CREAT );
if ( defined $fh ) {
    unless ( $tds->writeToFileHandle( $fh ) == AZ_OK ) {
       finish("FATAL ERROR: Could not store $tds_filename: $!");
    }
	undef $fh;
}
else {
    finish("FATAL ERROR: Could not create $package.zip: $!");
}
add_zip( 0, $tds_filename, '' );

# Save the Zip file
$fh = FileHandle->new( "$package.zip", O_WRONLY|O_TRUNC|O_CREAT );
if ( defined $fh ) {
    unless ( $zip->writeToFileHandle( $fh ) == AZ_OK ) {
       finish("FATAL ERROR: Could not store $package.zip: $!");
    }
	undef $fh;
}
else {
    finish("FATAL ERROR: Could not create $package.zip: $!");
}

remove_intermediary_files();
remove( '*-example.pdf' ); # deleting PDFs in the above loop destroys the archive!
remove( $tds_filename ) if !$DEBUG;
    


###############
# EXIT SCRIPT #
###############

finish("Job regularly finished!");


###############
# SUBROUTINES #
###############

# append arguments to build log file
sub add_log {
	#$log .= join('',(@_,$newline));
	print @_,"\n";
}

# adds a file (arg 1) to the archive member (arg 2) and converts CRLF to LF
sub add_zip {
	
	my $mode = shift; # 0 = common, 1 = TDS
    my $filename = shift;
    my $dir = shift;	
	
	my $z = $zip;
	$z = $tds if $mode;
          
	add_log("Trying to open file ", $filename, "\n");
    if ($filename !~ /\.(pdf|zip)$/) {

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
            
            my $member = $z->addString( $text, "$dir/$filename", COMPRESSION_LEVEL_BEST_COMPRESSION );
			
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

        my $member = $z->addFile( $filename, "$dir/$filename", COMPRESSION_LEVEL_BEST_COMPRESSION );
        add_log("File $filename successfully added to ZIP archive.\n");
		
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
    
	#my $logfh = FileHandle->new('ctanify.log', O_WRONLY|O_TRUNC|O_CREAT);
    
    my $exectime = (time - $time)/60;
    add_log("Script execution lasted $exectime minutes\n");
    
	#if (defined $logfh) {
	#	print $logfh $log;
	#	die "\n$log";
	#}
	#else {die "FATAL ERROR: Could not write build log: $!"}
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

sub handle_file {
   
   my $file = $_;
   
   add_zip( 1, $file, $tds_bib ) if $file =~ /\.bib$/;
   add_zip( 1, $file, $tds_tex ) if $file =~ /\.[bcdl]bx$/;
   
}