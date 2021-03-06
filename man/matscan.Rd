% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/misc.R
\name{matscan}
\alias{matscan}
\title{Read matrix data from a file}
\usage{
matscan(file, num.cols = count.fields(file)[1], what = 0, sk = 0)
}
\arguments{
\item{file}{A filename.}

\item{num.cols}{The number of columns of data in the file.}

\item{what}{A template for the data elements in the file, it should be a
number for numeric data (the default) or a string for string data. Note
that an Splus matrix can only hold one type of data (string or numeric),
for mixed types use data tables and the \code{read.table} function.}

\item{sk}{The number of leading lines of the file to skip.}
}
\value{
A matrix corresponding to the data in \code{file}.
}
\description{
Reads matrix data from a file
}
\details{
This function has been partially superceeded by the introduction of data
frames and the read.table function.  It is still useful however for reading
data into Splus matrix objects.
}
\seealso{
read.table
}
\keyword{misc}

