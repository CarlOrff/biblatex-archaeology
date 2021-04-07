chcp 65001
call cleanup.bat

SET biber=%USERPROFILE%\Documents\ingram\texmf\bin\biber\biber.exe
SET biber=biber

SET engine=xelatex
SET engine=pdflatex
SET engine=lualatex

%engine% -file-line-error -halt-on-error biblatex-archaeology_example
%biber% --trace biblatex-archaeology_example
%engine% -file-line-error -halt-on-error biblatex-archaeology_example
%engine% -file-line-error -halt-on-error biblatex-archaeology_example
texworks biblatex-archaeology_example.pdf
pause>nul