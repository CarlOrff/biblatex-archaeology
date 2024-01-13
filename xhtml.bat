call cleanup.bat
make4ht -ulf xhtml -e mycfg.mk4 biblatex-archaeology_example.tex "fn-in"
start biblatex-archaeology_example.html
pause>nul