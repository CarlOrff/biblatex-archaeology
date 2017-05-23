REM install the biblatex-archaeology package 

REM remove outdated files
call cleanup.bat
del *.bbx *.cbx *.dbx *.lbx *.sty

REM install from .dtx
TEX biblatex-archaeology.ins

REM update package database
texhash

REM make example
call example.bat

pause>nul