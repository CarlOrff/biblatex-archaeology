REM install the biblatex-archaeology package
chcp 65001
call cleanup.bat
call bibtex.bat
del biblatex-archaeology.pdf
perl abbrev.pl
call cleanup.bat
lualatex -file-line-error biblatex-archaeology.dtx
Biber biblatex-archaeology
perl datamodel.pl
call cleanup.bat
lualatex -file-line-error biblatex-archaeology.dtx
Biber biblatex-archaeology
lualatex -file-line-error biblatex-archaeology.dtx
makeindex -s gglo.ist -o biblatex-archaeology.gls biblatex-archaeology.glo
makeindex -s gind.ist biblatex-archaeology.idx
lualatex -file-line-error biblatex-archaeology.dtx
lualatex -file-line-error biblatex-archaeology.dtx
texworks biblatex-archaeology.pdf
pause>nul