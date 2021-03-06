% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/get.trackdata.R
\name{get.trackdata}
\alias{get.trackdata}
\title{get.trackdata(): get trackdata from emuDB object}
\usage{
get.trackdata(dbObj, seglist = NULL, ssffTrackName = NULL, cut = NULL,
  npoints = NULL, onTheFlyFunctionName = NULL, onTheFlyParams = NULL,
  onTheFlyOptLogFilePath = NULL, nrOfAllocationRows = 10000,
  verbose = TRUE)
}
\arguments{
\item{dbObj}{emuDB object that the trackdata will be extracted from}

\item{seglist}{seglist obtained by querying the emuDB object}

\item{ssffTrackName}{the name of track that one wishes to extract (see
\code{dbObj$DBconfig$ssffTrackDefinitions} for the defined ssffTracks of the
dbObj). If the parameter \code{onTheFlyFunctionName} is set then
this corresponds to the column name af the AsspDataObj (see
wrasspOutputInfos$<wrassp-function-name>$tracks).}

\item{cut}{An optional cut time for segment data, ranges between
0 and 1, a value of 0.5 will extract data only at the segment midpoint.}

\item{npoints}{An optional number of points to retrieve for each segment or event.
For segments this requires a cut= argument and data is extracted around the cut time.
For events data is extracted around the event time. If npoints is an odd number the
samples are centered around the cut-time-sample, if not they are sqewed to the
right by one sample.}

\item{onTheFlyFunctionName}{name of wrassp function to do on-the-fly calculation}

\item{onTheFlyParams}{a list parameters that will be given to the function
passed in by the onTheFlyFunctionName parameter. This list can easily be
generated using the \code{formals} function and then setting the according
parameter one wishes to change.}

\item{onTheFlyOptLogFilePath}{path to log file for on-the-fly function}

\item{nrOfAllocationRows}{If the size limit of the data matrix is reached
a further nrOfAllocationRows more rows will be allocated (this will lead
performance drops).}

\item{verbose}{show progress bars and other infos}
}
\value{
If \code{dcut} is not set (the default) an object of type trackdata
is returned. If \code{dcut} is set and \code{npoints} is not, or the seglist
is of type event and npoints is not set a data.frame is returned
}
\description{
Extract trackdata information from a given emuDB object that
corresponds to the entries in a segment list.
}
\details{
This is the emuR equivalent of the depricated \code{emu.track()}
function. It utilizes the wrassp package for signal processing and
SSFF/audio file handling. It reads time relevant data from a given
segmentlist, extracts the specified trackdata and places it into a
trackdata object (analogous to the depricated emu.track).
}
\author{
Raphael Winkelmann
}
\seealso{
\code{\link{formals}}, \code{\link{wrasspOutputInfos}}, \code{\link{trackdata}}
}
\keyword{misc}

