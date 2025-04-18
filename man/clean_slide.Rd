% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compile-slides.R
\name{clean_slide}
\alias{clean_slide}
\title{Clean output for a single .tex file}
\usage{
clean_slide(slide_file, keep_pdf = FALSE, verbose = FALSE)
}
\arguments{
\item{slide_file}{\verb{[character(1)]} Name of a (single) slide, with or without \code{.tex} extension. See examples of \code{\link[=find_slide_tex]{find_slide_tex()}}.}

\item{keep_pdf}{\verb{[FALSE]}: Keep the PDF file.}

\item{verbose}{\verb{[TRUE]}: Print additional output to the console.}
}
\value{
Invisibly: A list with entries
\itemize{
\item passed: TRUE indicates a successful compilation, FALSE a failure.
\item log: Absolute path to the log file in case of a non-zero exit status.
}
}
\description{
Uses \verb{latexmk -C <slide_file>}, also removing the PDF file.
Uses \verb{latexmk -c <slide_file>} to keep the PDF file.
}
\examples{
\dontrun{
# Create the PDF
compile_slide("slides-cart-computationalaspects.tex")

# Remove the PDF and other output
clean_slide("slides-cart-computationalaspects.tex")
}
}
