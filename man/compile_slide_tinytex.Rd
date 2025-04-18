% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compile-slides.R
\name{compile_slide_tinytex}
\alias{compile_slide_tinytex}
\title{Compile a .tex file using TinyTex's latexmk emulation}
\usage{
compile_slide_tinytex(slide_file, margin, ...)
}
\arguments{
\item{slide_file}{\verb{[character(1)]} Name of a (single) slide, with or without \code{.tex} extension. See examples of \code{\link[=find_slide_tex]{find_slide_tex()}}.}

\item{margin}{\verb{[TRUE]} By default renders slides with margin. Otherwise a 4:3 slide is
rendered.}

\item{...}{Arguments passed to \code{\link[tinytex:latexmk]{tinytex::latexmk()}}.}
}
\value{
\code{TRUE} if an output PDF file exists, \code{FALSE} otherwise.
}
\description{
TinyTex's \code{\link[tinytex:latexmk]{tinytex::latexmk()}} automatically installs missing LaTeX packages,
making it very useful.
This is just a thin wrapper run the command with
a changed working directory, as relative paths used in \code{preamble.tex} etc. require.
}
\examples{
\dontrun{
compile_slide_tinytex("lecture_advml/slides/gaussian-processes/slides-gp-basic-3.tex")
}
}
