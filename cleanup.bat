REM Prepares the biblatex-archaeology development environment for a new run
 
REM change shell colours and code page
color 5F
chcp 65001

REM remove intermediate and output files even from subfolders
del /S *.4ct *.4tc *.aux *.bbl *.bcf *.blg *.conf *.css *.dvi *.epub *.fdb_latexmk *.fls *.glg *.glo *.gls *.hd *.html *.idv *.idx *.ilg *.ind *.lg *.lof *.log *.lot *.ncx *.odt *.opf *.out *.run.xml *.tmp *.toc *.xdv *.xmpdata *.xmpi *.xref biblatex-archaeology_example.pdf

REM remove the utf2ent.pl converted files
del example-ent.*

IF EXIST biblatex-archaeology (
	REM remove the extracted zip archive
	rd /S /Q biblatex-archaeology
)

IF EXIST biblatex-archaeology_example-epub (
	REM remove the extracted zip archive
	rd /S /Q biblatex-archaeology_example-epub
)
