call cleanup.bat
make4ht -lf html5 -e mycfg.mk4 biblatex-archaeology_example.tex "fn-in"
start biblatex-archaeology_example.html
pause>nul