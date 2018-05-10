REM install the biblatex-archaeology package

call cleanup.bat
pdflatex -file-line-error biblatex-archaeology.dtx
Biber biblatex-archaeology
pdflatex -file-line-error biblatex-archaeology.dtx
makeindex -s gglo.ist -o biblatex-archaeology.gls biblatex-archaeology.glo
makeindex -s gind.ist biblatex-archaeology.idx
pdflatex -file-line-error biblatex-archaeology.dtx
pdflatex -file-line-error biblatex-archaeology.dtx
texworks biblatex-archaeology.pdf
pause>nul