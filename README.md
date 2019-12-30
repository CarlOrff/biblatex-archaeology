# The `biblatex-archaeology` styles [v2.2]

## Objective

`biblatex-archaeology` provides a collection of style files for the `biblatex` bibliography package. It is designed for the use of German researchers into material culture, especially prehistorians and medieval archaeologists. Generally their bibliography styles are more or less variations of the [guide lines of the Römisch-Germanische Kommission (RGK)](https://www.uni-bamberg.de/fileadmin/uni/fakultaeten/ggeo_professuren/fruehgesch_archaeologie/Dateien/RGK_Richtlinien.pdf), nowithstanding of being verbose or inline styles. I tried to develop generic styles, that cover all the needs and allow for easy generation of local styles. Refer to the enclosed manual document for further details.

## Installing

The usual way is to install automatically through the package manager of your distribution. Another way ist to unzip the 
`biblatex-archaeology.tds.zip` in your `{TEXMF}` directory. To do everything from scratch, get the sources from [CTAN](http://www.ctan.org/pkg/biblatex-archaeology) or clone them from GitHub:

	 $ git clone https://github.com/CarlOrff/biblatex-archaeology.git

Create the directories `{TEXMF}/bibtex/bib/biblatex-archaeology` and `{TEXMF}/tex/latex/biblatex-archaeology` and run

	 $ pdftex -8bit biblatex-archaeology.ins
	 $ texhash
	
Create a directory `{TEXMF}/doc/latex/biblatex-archaeology` and move `biblatex-archaeology.pdf` and the example folder there. In case you want to compile the manual yourself, do 

	 $ lualatex biblatex-archaeology
	 $ Biber biblatex-archaeology
	 $ lualatex biblatex-archaeology
	 $ makeindex -s gind.ist biblatex-archaeology.idx
	 $ lualatex biblatex-archaeology
	 $ makeindex -s gglo.ist -o biblatex-archaeology.gls biblatex-archaeology.glo
	 $ lualatex biblatex-archaeology
	 $ makeindex -s gglo.ist -o biblatex-archaeology.gls biblatex-archaeology.glo
	 $ lualatex biblatex-archaeology
	 $ lualatex biblatex-archaeology

Remark that you MUST employ Biber. BibTeX won't work.

In contrast to CPAN the GitHub sources include Perl scripts and Windows batch files in addition. These are tools for speeding up the development process and have no meaning for end users.

## Usage

The package provides several style files for the `biblatex` bibliography package. It is called through `biblatex`' style option, fi.:

	\usepackage[style=rgk-verbose]{biblatex}

Remark that `biblatex-archaeology` makes heavy use of Biber-only features. It won't work properly with BibTeX as backend. For a detailed styles and commands reference refer to the manual. At present the following end user styles are provided:

- aefkw
- afwl
- amit
- archa
- dguf
- dguf-alt
- dguf-apa
- eaz
- eaz-alt
- foe
- jb-halle
- jb-kreis-neuss
- karl
- kunde
- maja
- mpk
- mpkoeaw
- niedersachsen
- nnu
- offa
- rgk-inline
- rgk-inline-old
- rgk-numeric
- rgk-numeric-old
- rgk-verbose
- rgk-verbose-old
- rgzm-inline
- rgzm-numeric
- rgzm-verbose
- ufg-muenster-inline
- ufg-muenster-numeric
- ufg-muenster-verbose
- volkskunde
- zaak
- zaes

## Help

The package is hosted on [GitHub](https://github.com/CarlOrff/biblatex-archaeology). If you have any concerns it is by far best to use the issue tracker there.
Alternatively you can e-mail me through the [contact form on my website](https://ingram-braun.net/erga/legal-notice-and-contact/#ib_campaign=biblatex-archaeology-v2.2&ib_medium=readme.md&ib_source=ctan&ib_content=helpsection). Or you can employ the comment script of a project page on my personal website: [The `biblatex-archaeology` styles for German cultural anthropology](https://ingram-braun.net/erga/the-biblatex-archaeology-styles-for-german-cultural-anthropology/#ib_campaign=biblatex-archaeology-v2.2&ib_medium=readme.md&ib_source=ctan&ib_content=helpsection).
gzm-dguf/
Normally you will get the latest production version through the update script of your TeX distribution. If you want to keep track actively, use
the news feeds of CTAN, GitHub, Academia or my personal website.

## Copyright

© 2005–2019 by [Ingram Braun](https://ingram-braun.net/#ib_campaign=biblatex-archaeology-v2.2&ib_medium=readme.md&ib_source=ctan&ib_content=copyright)

## License

[The LaTeX Project Public License 1.3c or later](http://www.latex-project.org/lppl.txt)