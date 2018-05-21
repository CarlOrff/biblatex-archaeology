REM install the biblatex-archaeology package
REM UTF-8
chcp 65001

REM remove outdated files
call cleanup.bat
del *.bbx *.cbx *.dbx *.lbx *.sty *.bib

REM install from .dtx
pdftex -8bit biblatex-archaeology.ins

REM update package database
texhash

REM make example
call example.bat

pause>nul