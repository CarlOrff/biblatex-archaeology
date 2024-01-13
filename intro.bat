chcp 65001
call cleanup.bat

SET biber=%USERPROFILE%\Documents\ingram\texmf\bin\biber\biber.exe
SET biber=biber

SET engine=xelatex
SET engine=pdflatex
SET engine=lualatex

%engine% -file-line-error -halt-on-error biblatex-archaeology_intro_de
%biber% --trace biblatex-archaeology_intro_de
::%engine% -file-line-error -halt-on-error biblatex-archaeology_intro_de
splitindex biblatex-archaeology_intro_de.idx
::makeindex -c biblatex-archaeology_intro_de.idx
%engine% -file-line-error -halt-on-error biblatex-archaeology_intro_de
texworks biblatex-archaeology_intro_de.pdf
pause>nul