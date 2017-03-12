REM convert biblatex-archaeology example file to MS Word
REM needs Perl installed!!
REM replace 'htlatex' with 'make4ht' if on MikTeX
REM Doesn't work if (n)german is main document language

del biblatex-archaeology_example-ent*

perl utf2ent.pl biblatex-archaeology_example.tex > biblatex-archaeology_example-ent.tex

REM HTML/MS Word:
htlatex biblatex-archaeology_example-ent.tex "html,word,fn-in" "symbol/!" "-cvalidate"

REM HTML:
::htlatex biblatex-archaeology_example-ent "xhtml,charset=utf-8" " -cunihtf -utf8"

::biber biblatex-archaeology_example-ent

perl utf2ent.pl biblatex-archaeology_example-ent.bbl > biblatex-archaeology_exampleexample-ent.bb_

copy /Y /A biblatex-archaeology_example-ent.bb_ biblatex-archaeology_example-ent.bbl /V

REM HTML/MS Word:
htlatex biblatex-archaeology_example-ent.tex "html,word,fn-in" "symbol/!" "-cvalidate"

REM HTML:
::htlatex biblatex-archaeology_example-ent "xhtml,charset=utf-8" " -cunihtf -utf8"

pause>nul