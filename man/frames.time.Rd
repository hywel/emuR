% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/dfuns.R
\name{frames.time}
\alias{frames.time}
\title{Find the time and position of a data element.}
\usage{
frames.time(dataset, datanum)
}
\arguments{
\item{dataset}{A dataset returned by \code{track} or \code{frames}.}

\item{datanum}{An integer, an index into the \code{data} component of
\code{dataset}.}
}
\value{
The segment number which contains the element \code{datanum} of
\code{dataset$data}.
}
\description{
Finds the time and position of a data element.
}
\details{
The dataset returned from \code{track} or \code{frames} consists of a
matrix of data (the \code{data} component) and two index components
(\code{index} and \code{ftime}). The data for all segments is concatenated
together in \code{$data}.  This function can be used to find out which
segment a particular row of \code{$data} corresponds to.
}
\seealso{
track, frames
}
\keyword{misc}

