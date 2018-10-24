call cleanup.bat

SET jobname=nocite
SET document="\documentclass[12pt]{scrartcl}\usepackage{csquotes}\usepackage[style=mpkoeaw,]{biblatex}\IfFileExists{ingram-braun-local.sty}{\usepackage{ingram-braun-local}\addbibresource{\IBbibstrrgk}\addbibresource{\IBbibmain}}{\addbibresource{biblatex-examples.bib}}\begin{document}\nocite{*}\printbibliography\end{document}"

lualatex -file-line-error -jobname=%jobname% %document%

%USERPROFILE%\Documents\ingram\texmf\bin\biber.exe --trace %jobname%
::Biber %jobname%

lualatex -file-line-error -jobname=%jobname% %document%

texworks %jobname%.pdf