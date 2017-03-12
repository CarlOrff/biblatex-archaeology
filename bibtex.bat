set INBIB=%USERPROFILE%/Documents/ingram/Texte/bib/ingram.bib
call cleanup.bat
pdflatex -file-line-error biblatex-archaeology.dtx
lualatex -file-line-error biblatex-archaeology_example
perl bibextract.pl biblatex-archaeology biblatex-archaeology-manual.bib %INBIB%
perl bibextract.pl example biblatex-archaeology-examples.bib %INBIB%
call cleanup.bat
pause>nul