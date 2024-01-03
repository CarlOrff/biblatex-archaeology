REM install the biblatex-archaeology package
chcp 65001
call cleanup.bat
call bibtex.bat
del biblatex-archaeology.pdf
perl abbrev.pl
call cleanup.bat
lualatex -file-line-error -halt-on-error biblatex-archaeology.dtx
::%USERPROFILE%\Documents\ingram\texmf\bin\biber.exe --trace biblatex-archaeology
Biber biblatex-archaeology
perl datamodel.pl
call cleanup.bat
lualatex -file-line-error -halt-on-error biblatex-archaeology.dtx
::%USERPROFILE%\Documents\ingram\texmf\bin\biber.exe --trace biblatex-archaeology
Biber biblatex-archaeology
lualatex -file-line-error -halt-on-error biblatex-archaeology.dtx
makeindex -s gind.ist biblatex-archaeology.idx
lualatex -file-line-error -halt-on-error biblatex-archaeology.dtx
makeindex -s gglo.ist -o biblatex-archaeology.gls -t biblatex-archaeology.glg biblatex-archaeology.glo
lualatex -file-line-error -halt-on-error biblatex-archaeology.dtx
:: The doubling is neccessary to make glossaries consider its own length:
makeindex -s gglo.ist -o biblatex-archaeology.gls -t biblatex-archaeology.glg biblatex-archaeology.glo
lualatex -file-line-error -halt-on-error biblatex-archaeology.dtx
lualatex -file-line-error -halt-on-error biblatex-archaeology.dtx
texworks biblatex-archaeology.pdf
pause>nul