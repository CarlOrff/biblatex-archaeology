REM compile the biblatex-archaeology example document
call cleanup.bat
lualatex -file-line-error biblatex-archaeology_example
biber biblatex-archaeology_example 
lualatex -file-line-error biblatex-archaeology_example
lualatex -file-line-error biblatex-archaeology_example
texworks biblatex-archaeology_example.pdf
pause>nul