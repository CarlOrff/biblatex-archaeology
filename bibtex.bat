set INBIB=%USERPROFILE%/Documents/ingram/Texte/bib/ingram.bib
call cleanup.bat
pdflatex -file-line-error biblatex-archaeology.dtx
lualatex -file-line-error biblatex-archaeology_example
perl bibextract.pl biblatex-archaeology biblatex-archaeology-nodoc.dtx manualBIB %INBIB%
perl bibextract.pl example biblatex-archaeology.dtx exampleBIB %INBIB%
call cleanup.bat
pause>nul