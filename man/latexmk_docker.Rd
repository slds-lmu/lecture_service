% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/latexmk.R
\name{latexmk_docker}
\alias{latexmk_docker}
\title{Run dockerized latexmk}
\usage{
latexmk_docker(
  slide_file,
  verbose = TRUE,
  tag = "TL2023-historic",
  log_stdout = "",
  log_stderr = "",
  supervise = TRUE
)
}
\arguments{
\item{slide_file}{\verb{[character(1)]} Name of a (single) slide, with or without \code{.tex} extension. See examples of \code{\link[=find_slide_tex]{find_slide_tex()}}.}

\item{verbose}{\verb{[TRUE]}: Print output from \code{docker}/\code{latexmk} to console.}

\item{tag}{\verb{["TL2023-historic"]}: Tag of \code{texlive} docker image to use.}

\item{log_stdout, log_stderr}{\verb{[""]}: Path to write stdout/stderr log to.
Discared if \code{NULL} or inherited from main R process if \code{""}.
\code{stderr} can be redirected to \code{stdout} with \code{"2>&1"}.}

\item{supervise}{\verb{[TRUE]}: Passed to \code{\link[processx:process]{processx::process()}}'s \verb{$new()}.}
}
\value{
A \code{\link[processx:process]{processx::process()}} object.
}
\description{
This uses the docker image from \url{https://gitlab.com/islandoftex/images/texlive}.
The default uses tag \code{TL2023-historic} for TeXLive 2023.
}
\details{
You will need to install docker or podman or some other compatible runtime on your system beforehand.

The docker command run by this is equivalent to something like

\if{html}{\out{<div class="sourceCode sh">}}\preformatted{cd path/to/lecture_i2ml/slides/ml-basics

CWD=$(basename $\{PWD\})
LECTURE=$(dirname $(dirname $\{PWD\}))

docker run -i --rm --user $(id -u) --name latex \\
  -v "$\{LECTURE\}":/usr/src/app:z \\
  -w "/usr/src/app/slides/$\{CWD\}" \\
  registry.gitlab.com/islandoftex/images/texlive:TL2023-historic \\
  latexmk -pdf -halt-on-error slides-basics-data.tex
}\if{html}{\out{</div>}}
}
\note{
This utility is usually invoked by \code{\link[=compile_slide]{compile_slide()}}.
}
\examples{
\dontrun{
latexmk_docker("slides-cart-treegrowing.tex")
}
}
