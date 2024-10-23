#! /usr/bin/env Rscript

# if (!("tinytex" %in% installed.packages())) install.packages("tinytex")
# if (!tinytex::is_tinytex()) {
#   warning("Please install tinytex: tinytex::install_tinytex()")
# }

has_tinytex <- "tinytex" %in% installed.packages()
tinytex_installed <- FALSE
if (has_tinytex) {
  tinytex_installed <- tinytex::is_tinytex()
}

tl_check <- processx::run("tlmgr", args = "--version")

if (tl_check$status != 0) {
  cli::cli_alert_danger("TeX Live / tlmgr not found, please install it:")
  cli::cli_li(c(
    "{.code install.packages(\"tinytex\")}",
    "{.fun tinytex::install_tinytex}"
  ))
  cli::cli_abort("Re-run once TeX Live is installed")
}

tl_version <- stringr::str_extract(tl_check$stdout, "20\\d{2}")
cli::cli_alert_info("Found TeX Live version {tl_version}")
if (tl_version != "2024") {
  cli::cli_alert_danger("Slides assume TeX Live 2024, please update to avoid issues:")
  cli::cli_inform("{.fun tinytex::reinstall_tinytex}")
}

# Script to extract packages didn't work on GH so I ran tinytex::latexmk()
# interactively via tmate and just.. wrote down the pkg it installed.
# ...if it works it works. I guess.
manually_selected_deps <- c(
  # The first batch are packages generally used throughout all lectures
  "beamer",
  "framed",
  "fp",
  # "ms", # not present in repository (TL 2024, 2024-10-23)
  "pgf",
  "translator",
  "colortbl",
  "babel-english",
  "doublestroke", # package is named doublestroke for installing, but \usepackage{dsfont} for loading!
  "csquotes",
  "multirow",
  "textpos",
  "psfrag",
  "algorithms",
  "algorithmicx",
  "eqnarray", # should be substituted with amsmath's align env, see https://texfaq.org/FAQ-eqnarray
  "arydshln",
  "placeins",
  "setspace",
  "mathtools",
  "wrapfig",
  "subfig",
  "caption",
  "bbm-macros",
  # Below are packages specifically added in iml or optim
  "transparent", # lecture_sl/slides/boosting/slides-boosting-cwb-basics2.tex
  "adjustbox",   # optim and iml, lecture_optimization/slides/01-mathematical-concepts/slides-concepts-3-convexity.tex and cheatsheets
  "verbatimbox", # optim, 07-derivative-free/slides-optim-derivative-free-4-multistart-optimization
  "forloop",     # same loc
  "listofitems", # optim, slides-optim-derivative-free-4-multistart-optimization // Do not know why this is needed though
  "tcolorbox",   # iml, 01_intro/slides05-intro-interaction.tex
  "siunitx",     # iml, 04_shapley/slides04-shap.tex, but used in latex-math anyway
  "pdfpages",    # iml, but why?
  # All of the following were iml-specific dependencies I have not investigated specifically
  # Ideally we'd be able to identify which dependency is included for which purposes/feature
  # to avoid having to install a bag of mystery packages just to keep the latex demon happy.
  "xifthen",
  "footmisc",
  "tikzmark",
  "ifmtarg",
  "textcase", # \citelink (\NoCaseChange)
  "pdflscape",
  "makecell",
  "environ",
  "trimspaces",
  "tikzfill",
  "pdfcol",
  "listings",
  "listingsutf8",
  "readarray",
  # pdfannotextractor, useful to restore clickability of links in includepdf'd document
  # Also used in iml in Makefile rule
  "pax",
  # Only needed for Docker container?
  "booktabs",
  "float",
  "biblatex", # \citelink
  "usebib",   # \citelink
  "biber",     # \citelink
  # for exercises, based on lecture_sl/advriskmin
  "a4wide",
  "ntgclass",
  "paralist",
  "xfrac",
  "bytefield",
  "cancel"
)

if (tinytex_installed) {
  cli::cli_alert_info("Attempting to install manually selected LaTeX dependencies via {.fun tinytex::tlmgr_install}")
  tinytex::tlmgr_install(manually_selected_deps)
} else {
  cli::cli_alert_info("Attempting to install manually selected LaTeX dependencies via system tlmgr")
  processx::run("tlmgr", args = c("install", manually_selected_deps))
}

# Unused but maybe useful in the future ---------------------------------------------------------------------------

if (FALSE) {
  # List of installed packages in a fresh TinyTeX installation on GitHub actions using default settings:
  default_installed <- "amscls
amsfonts
amsmath
atbegshi
atveryend
auxhook
babel
bibtex
bibtex.universal-darwin
bigintcalc
bitset
booktabs
cm
ctablestack
dehyph
dvipdfmx
dvipdfmx.universal-darwin
dvips
dvips.universal-darwin
ec
epstopdf-pkg
etex
etexcmds
etoolbox
euenc
everyshi
fancyvrb
filehook
firstaid
float
fontspec
framed
geometry
gettitlestring
glyphlist
graphics
graphics-cfg
graphics-def
helvetic
hycolor
hyperref
hyph-utf8
hyphen-base
iftex
inconsolata
infwarerr
intcalc
knuth-lib
kpathsea
kpathsea.universal-darwin
kvdefinekeys
kvoptions
kvsetkeys
l3backend
l3kernel
l3packages
latex
latex-amsmath-dev
latex-bin
latex-bin.universal-darwin
latex-fonts
latex-tools-dev
latexconfig
latexmk
latexmk.universal-darwin
letltxmacro
lm
lm-math
ltxcmds
lua-alt-getopt
lua-uni-algos
luahbtex
luahbtex.universal-darwin
lualatex-math
lualibs
luaotfload
luaotfload.universal-darwin
luatex
luatex.universal-darwin
luatexbase
mdwtools
metafont
metafont.universal-darwin
mfware
mfware.universal-darwin
modes
natbib
pdfescape
pdftex
pdftex.universal-darwin
pdftexcmds
plain
psnfss
refcount
rerunfilecheck
scheme-infraonly
selnolig
stringenc
symbol
tex
tex-ini-files
tex.universal-darwin
texlive-scripts
texlive-scripts.universal-darwin
texlive.infra
texlive.infra.universal-darwin
times
tipa
tools
unicode-data
unicode-math
uniquecounter
url
xcolor
xetex
xetex.universal-darwin
xetexconfig
xkeyval
xunicode
zapfding"

  default_installed <- unlist(strsplit(default_installed, "\n"))

  latex_packages <- list.files("lecture_sl/style", pattern = "*.tex", recursive = TRUE, full.names = TRUE) |>
    lapply(\(x) grep("^\\\\usepackage", readLines(x), value = TRUE)) |>
    unlist() |>
    stringr::str_subset("lmu-lecture", negate = TRUE) |>
    stringr::str_extract_all("\\{\\w*\\}") |>
    unlist() |>
    stringr::str_remove_all("\\{|\\}") |>
    stringr::str_split(",") |>
    unlist()

  # This has a different name on CTAN, unhelpfully, is required for latex-math though
  if ("dsfont" %in% latex_packages) {
    latex_packages[latex_packages == "dsfont"] <- "doublestroke"
  }

  # Kind of important.
  latex_packages <- union("beamer", latex_packages)

  # Unfortunately some pkgs are preinstalled everywhere but not listed by tlmgr list --only-installed (inputenc, babel...)
  missing <- setdiff(latex_packages, default_installed)
  missing <- latex_packages[which(tinytex::check_installed(missing))]

  cli::cli_inform("Found the following possibly missing LaTeX packages: {missing}")
  cli::cli_alert_info("Attemtping to install them via {.fun tinytex::tlmgr_install}")
  tinytex::tlmgr_install(missing)
}
