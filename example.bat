REM compile the biblatex-archaeology example document
chcp 65001
call cleanup.bat
pdflatex -file-line-error -halt-on-error biblatex-archaeology_example
::lualatex -file-line-error -halt-on-error biblatex-archaeology_example
::%USERPROFILE%\Documents\ingram\texmf\bin\biber.exe --trace biblatex-archaeology_example
biber --trace biblatex-archaeology_example
pdflatex -file-line-error -halt-on-error biblatex-archaeology_example
::lualatex -file-line-error -halt-on-error biblatex-archaeology_example
texworks biblatex-archaeology_example.pdf
pause>nul