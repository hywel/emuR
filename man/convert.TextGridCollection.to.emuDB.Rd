% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/convert.TextGridCollection.R
\name{convert.TextGridCollection.to.emuDB}
\alias{convert.TextGridCollection.to.emuDB}
\title{Convert a TextGridCollection (.wav & .TextGrid files) to a emuDB}
\usage{
convert.TextGridCollection.to.emuDB(path2rootDir, dbName, targetDir,
  tgExt = "TextGrid", audioExt = "wav", tierNames = NULL,
  showProgress = TRUE)
}
\arguments{
\item{path2rootDir}{path to root directory (CAUTION: think of DB size and search space!)}

\item{dbName}{name given to newly generated emuDB}

\item{targetDir}{directory where to save newly generated emuDB}

\item{tgExt}{extention of TextGrid files (default=TextGrid meaning filesnames of the form baseName.TextGrid)}

\item{audioExt}{extention of audio files (default=wav meaning filesnames of the form baseName.wav).}

\item{tierNames}{character vector containing names of tiers to extract and convert. If NULL (the default) all
tiers are converted.}

\item{showProgress}{show progress bar flag}
}
\description{
Converts a TextGridCollection to a emuDB by first generating a file pair list
containing the paths to the .wav & .TextGrid (default extentions) files with the same base
name. It then generates a emuDB DBconfig from the first TextGrid in this file pair list.
After this it converts all file pairs to the new format.
}
\author{
Raphael Winkelmann
}
\seealso{
create.filePairList
}

