REM install the biblatex-archaeology package
call bibtex.bat
del biblatex-archaeology.pdf
perl abbrev.pl
pdflatex -file-line-error biblatex-archaeology.dtx
Biber biblatex-archaeology
makeindex -s gglo.ist -o biblatex-archaeology.gls biblatex-archaeology.glo
makeindex -s gind.ist biblatex-archaeology.idx
pdflatex -file-line-error biblatex-archaeology.dtx
pdflatex -file-line-error biblatex-archaeology.dtx
texworks biblatex-archaeology.pdf
pause>nul