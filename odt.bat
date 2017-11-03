call cleanup.bat
mk4ht oolatex biblatex-archaeology_example "xhtml, charset=utf-8" -utf8
%USERPROFILE%\Documents\ingram\texmf\bin\biber.exe biblatex-archaeology_example
::biber biblatex-archaeology_example
mk4ht oolatex biblatex-archaeology_example "xhtml, charset=utf-8"  -utf8
start biblatex-archaeology_example.odt