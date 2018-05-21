REM compile the biblatex-archaeology example document
chcp 65001
call cleanup.bat
lualatex -file-line-error biblatex-archaeology_example
::%USERPROFILE%\Documents\ingram\texmf\bin\biber.exe biblatex-archaeology_example
biber biblatex-archaeology_example
lualatex -file-line-error biblatex-archaeology_example
lualatex -file-line-error biblatex-archaeology_example
texworks biblatex-archaeology_example.pdf
pause>nul