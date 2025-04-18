% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/repo_status.R
\name{repo_status}
\alias{repo_status}
\title{Lecture repo status}
\usage{
repo_status(lecture = lectures())
}
\arguments{
\item{lecture}{Character vector of lecture repo names, defaults to \code{lectures()}.
E.g. \code{c("lecture_advml", "lecture_i2ml")}.}
}
\value{
A \code{data.frame} suitable for display via \code{kable} in RMarkdown.
}
\description{
Show latest changes to locally available lectures.
}
\examples{
if (FALSE) repo_status()
}
