#! /usr/bin/env Rscript

# Step 1: Check if tinytex R package is installed
has_tinytex_pkg <- "tinytex" %in% installed.packages()

if (!has_tinytex_pkg) {
  cli::cli_alert_warning("The {.pkg tinytex} R package is not installed")
  cli::cli_inform("Installing {.pkg tinytex} package...")
  install.packages("tinytex", repos = "https://cloud.r-project.org")
  has_tinytex_pkg <- TRUE
}

# Step 2: Check if tlmgr is available on the system
tlmgr_available <- FALSE
tl_check <- tryCatch({
  processx::run("tlmgr", args = "--version", error_on_status = FALSE)
}, error = function(e) {
  list(status = 1)
})

tlmgr_available <- tl_check$status == 0

# Step 3: Check if the LaTeX installation is from tinytex (if any)
is_tinytex_install <- FALSE
if (tlmgr_available && has_tinytex_pkg) {
  is_tinytex_install <- tinytex::is_tinytex()
}

# Step 4: Handle missing LaTeX installation
if (!tlmgr_available) {
  cli::cli_alert_danger("No LaTeX installation found (tlmgr not available)")
  cli::cli_inform("")
  cli::cli_alert_info("TinyTeX can be installed automatically:")
  cli::cli_ul(c(
    "TinyTeX is a lightweight, cross-platform LaTeX distribution",
    "Recommended for R users and CI/CD environments",
    "Takes ~100MB of disk space for base installation"
  ))
  cli::cli_inform("")
  
  response <- readline(prompt = "Install TinyTeX now? [Y/n]: ")
  
  if (tolower(trimws(response)) %in% c("", "y", "yes")) {
    cli::cli_alert_info("Installing TinyTeX via {.fun tinytex::install_tinytex}...")
    tinytex::install_tinytex()
    is_tinytex_install <- TRUE
    tlmgr_available <- TRUE
    cli::cli_alert_success("TinyTeX installed successfully")

    # Re-run tlmgr --version to get version info
    tl_check <- processx::run("tlmgr", args = "--version", error_on_status = FALSE)
  } else {
    cli::cli_alert_danger("Cannot proceed without a LaTeX installation")
    cli::cli_inform("Please install either:")
    cli::cli_ul(c(
      "TinyTeX: {.code tinytex::install_tinytex()}",
      "Or a full TeX Live distribution from your system package manager"
    ))
    cli::cli_abort("Re-run this script once LaTeX is installed")
  }
}

# Step 5: Warn if using non-TinyTeX installation
if (tlmgr_available && !is_tinytex_install) {
  cli::cli_alert_warning("Found a LaTeX installation, but it's not TinyTeX")
  cli::cli_inform("")
  cli::cli_inform("This should work, but TinyTeX is recommended because:")
  cli::cli_ul(c(
    "Better integration with R",
    "Easier package management",
    "Consistent across platforms"
  ))
  cli::cli_inform("")
  cli::cli_alert_info("Continuing with your existing LaTeX installation...")
  cli::cli_inform("If you encounter issues, consider installing TinyTeX: {.fun tinytex::install_tinytex}")
  cli::cli_inform("")
}

# Now that we know tlmgr is available, get version info
tl_version_raw <- stringr::str_extract(tl_check$stdout, "20\\d{2}")
tl_version <- as.integer(tl_version_raw)

# Check if version extraction was successful
if (length(tl_version) == 0 || is.na(tl_version)) {
  cli::cli_alert_warning("Could not determine TeX Live version from tlmgr output")
  cli::cli_inform("Proceeding anyway, but some features may not work correctly")
  tl_version <- NA
} else {
  cli::cli_alert_info("Found TeX Live version {tl_version}")

  # Accept TeX Live 2024 or newer
  min_version <- 2024
  if (tl_version < min_version) {
    cli::cli_alert_warning(
      "TeX Live {tl_version} is older than recommended minimum ({min_version})"
    )
    cli::cli_inform(
      "Please update if you run into issues: {.fun tinytex::reinstall_tinytex}"
    )
  } else {
    cli::cli_alert_success("TeX Live {tl_version} meets requirements (>= {min_version})")
  }
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
  "enumitem", # Supersedes 'enumerate', still WIP, used in custom itemize envs
  # Below are packages specifically added in iml or optim
  "transparent", # lecture_sl/slides/boosting/slides-boosting-cwb-basics2.tex
  "adjustbox", # optim and iml, lecture_optimization/slides/01-mathematical-concepts/slides-concepts-3-convexity.tex and cheatsheets
  "verbatimbox", # optim, 07-derivative-free/slides-optim-derivative-free-4-multistart-optimization
  "forloop", # same loc
  "listofitems", # optim, slides-optim-derivative-free-4-multistart-optimization // Do not know why this is needed though
  "tcolorbox", # iml, 01_intro/slides05-intro-interaction.tex
  "siunitx", # iml, 04_shapley/slides04-shap.tex, but used in latex-math anyway
  "pdfpages", # iml, but why?
  # All of the following were iml-specific dependencies I have not investigated specifically
  # Ideally we'd be able to identify which dependency is included for which purposes/feature
  # to avoid having to install a bag of mystery packages just to keep the latex demon happy.
  "xifthen",
  "footmisc",
  "tikzmark",
  "ifmtarg",
  "fancyhdr",
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
  "xstring", # new macros
  # pdfannotextractor, useful to restore clickability of links in includepdf'd document
  # Also used in iml in Makefile rule
  "pax",
  # Only needed for Docker container?
  "booktabs",
  "float",
  "biblatex", # \citelink
  "usebib", # \citelink
  "biber", # \citelink
  # for exercises, based on lecture_sl/advriskmin
  "a4wide",
  "ntgclass",
  "paralist",
  "xfrac",
  "bytefield",
  "cancel",
  # cheatsheets
  "type1cm",
  "ragged2e",
  "mathdots"
)

if (is_tinytex_install) {
  cli::cli_alert_info(
    "Attempting to install manually selected LaTeX dependencies via {.fun tinytex::tlmgr_install}"
  )
  # Handle repository version mismatch for TeX Live 2024
  if (!is.na(tl_version) && tl_version == 2024) {
    cli::cli_alert_info("Configuring tlmgr repository for TeX Live 2024...")
    tryCatch({
      tinytex::tlmgr(c("option", "repository", "https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2024/tlnet-final"))
    }, error = function(e) {
      cli::cli_alert_warning("Could not set historic repository, trying default installation")
    })
  }
  tinytex::tlmgr_install(manually_selected_deps)
} else {
  cli::cli_alert_info(
    "Attempting to install manually selected LaTeX dependencies via system tlmgr"
  )
  # Handle repository version mismatch for TeX Live 2024
  if (!is.na(tl_version) && tl_version == 2024) {
    cli::cli_alert_info("Configuring tlmgr repository for TeX Live 2024...")
    tryCatch({
      processx::run("tlmgr", args = c("option", "repository", "https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2024/tlnet-final"))
    }, error = function(e) {
      cli::cli_alert_warning("Could not set historic repository, trying default installation")
    })
  }
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

  latex_packages <- list.files(
    "lecture_sl/style",
    pattern = "*.tex",
    recursive = TRUE,
    full.names = TRUE
  ) |>
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

  cli::cli_inform(
    "Found the following possibly missing LaTeX packages: {missing}"
  )
  cli::cli_alert_info(
    "Attemtping to install them via {.fun tinytex::tlmgr_install}"
  )
  tinytex::tlmgr_install(missing)
}

