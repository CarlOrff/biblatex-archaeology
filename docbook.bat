call cleanup.bat
make4ht -ulf docbook -e mycfg.mk4 biblatex-archaeology_example.tex
start biblatex-archaeology_example.xml
pause>nul