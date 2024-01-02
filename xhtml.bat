call cleanup.bat
make4ht -lf xhtml -e mycfg.mk4 biblatex-archaeology_example.tex "fn-in"
start biblatex-archaeology_example.html
pause>nul