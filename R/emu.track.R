##' emu.track
##' 
##' function stub to tell user that a new version is available
##' 
##' 
##' @keywords internal
##' @export
"emu.track" <- function (...) 
{
  stop('emu.track() is no longer available! Please use the S3 method get.trackdata() of the emuDB class!')
}


##' emu.track2
##' 
##' function stub to tell user that this function is no longer available
##' 
##' 
##' @keywords internal
##' @export
"emu.track2" <- function (...) 
{
  stop('emu.track2() is no longer available! Please use the S3 method get.trackdata() of the emuDB S3 class!')
}

#############################################
## commented out version of emu.track2:   ###
#############################################

##' Extract trackdata information for a given segmentlist
##' 
##' A new and improved version of emu.track that utilizes the wrassp package for 
##' signal processing and SSFF/audio file handling.
##' 
##' Reads time relevant data from a given segmentlist, extracts the specified
##' trackdata and places it into a trackdata object (analogos to the depricated emu.track). The
##' segmentlist$utts has to either contain valid paths to the signal files in which case the according
##' SSFF files have to be in the same folder or valid paths to the SSFF files
##' 
##' 
##' @param Seglist seglist obtained by querying a EMU DB
##' @param FileExtAndTrackName file extension and trackname separated by a ':' (e.g. fms:fm where fms is the 
##' file extension and fm is the track/column name). Default extensions and track/column names
##' are defined in the variable \code{wrasspOutputInfos} of the \code{wrassp} package.
##' @param PathToDbRootFolder is the path to the root dir of the Emu database; must be set, even if on-the-fly processing is applied 
##' (this might change in future versions)
##' @param cut An optional cut time for segment data, ranges between 0 and 1, a value of 0.5 will extract data only at the segment midpoint.
##' @param npoints An optional number of points to retrieve for each segment or event. For segments this requires a cut= argument and data is extracted around the cut time. For events data is extracted around the event time. If npoints is an odd number the samples are centered around the cut-time-sample, if not they are sqewed to the right by one sample.
##' @param OnTheFlyFunctionName name of wrassp function to do on-the-fly calculation 
##' @param OnTheFlyParas a list parameters that will be given to the function 
##' passed in by the OnTheFlyFunctionName parameter. This list can easily be 
##' generated using the \code{formals} function and then setting the according 
##' parameter one wishes to change.     
##' @param OnTheFlyOptLogFilePath path to log file for on-the-fly function
##' @param NrOfAllocationRows If the size limit of the data matrix is reached a further NrOfAllocationRows more rows will be allocated (this will lead performance drops). 
##' @param verbose show progress bars and other infos
##' @return If \code{dcut} is NOT set (the default) an object of type trackdata is returned. If \code{dcut} is set and \code{npoints} is NOT, or the seglist is of type event and npoints is not set a data.frame is returned
##' @author Raphael Winkelmann
##' @seealso \code{\link{formals}}
##' @keywords misc
##' @import wrassp
##' @export
# "emu.track2" <- function(Seglist = NULL, FileExtAndTrackName = NULL, PathToDbRootFolder = NULL,
#                          cut = NULL, npoints = NULL, OnTheFlyFunctionName = NULL, OnTheFlyParas = NULL, 
#                          OnTheFlyOptLogFilePath = NULL, NrOfAllocationRows = 1000000, verbose = TRUE){
#   
#   if( is.null(Seglist) || is.null(FileExtAndTrackName)) {
#     stop("Argument Seglist and FileExtAndtrackname are required.\n")
#   }
#   
#   ###########################
#   # split FileExtAndtrackname
#   splitQuery = unlist(strsplit(FileExtAndTrackName, ":"))
#   
#   fileExt = paste(".",splitQuery[1],sep="")
#   colName = splitQuery[2]
#   
#   ###################################
#   # update Seglist paths if neccesary
#   if(is.null(OnTheFlyFunctionName)){
#     Seglist = getFiles(Seglist, PathToDbRootFolder, fileExt, verbose=verbose)
#   }else{
#     Seglist = getFiles(Seglist, PathToDbRootFolder, '.wav', verbose=verbose)
#   }
#   
#   ####################################
#   # check if cut value is correct
#   if(!is.null(cut)){
#     if(cut < 0 || cut > 1){
#       stop('Bad value given for cut argument. Cut can only be a value between 0 and 1!')
#     }
#     if(emusegs.type(Seglist) == 'event'){
#       stop("Cut value should not be set if emusegs.type(Seglist) == 'event'!")
#     }
#   }
#   
#   ####################################
#   # check if npoints value is correct
#   if(!is.null(npoints)){
#     if(is.null(cut) && emusegs.type(Seglist) != 'event'){
#       stop('Cut argument hast to be set or seglist has to be of type event if npoints argument is used.')
#     }
#   }
#   
#   ###################################
#   #create empty index, ftime matrices
#   index <- matrix(ncol=2, nrow=length(Seglist$utts))
#   colnames(index) <- c("start","end")
#   
#   ftime <- matrix(ncol=2, nrow=length(Seglist$utts))
#   colnames(ftime) <- c("start","end")
#   
#   data <- NULL
#   origFreq <- NULL
#   
#   
#   ########################
#   # preallocate data (needs first element to be read)
#   if(!is.null(OnTheFlyFunctionName)){
#     funcFormals = NULL
#     funcFormals$listOfFiles = Seglist$utts[1]
#     funcFormals$ToFile = FALSE
#     curDObj = do.call(OnTheFlyFunctionName,funcFormals)
#   }else{
#     curDObj <- read.AsspDataObj(Seglist$utts[1])
#   }
#   tmpData <- eval(parse(text = paste("curDObj$", colName, sep = "")))
#   if(verbose){
#     cat('\n  INFO: preallocating data matrix with:', ncol(tmpData), ',', NrOfAllocationRows, 
#         'columns and rows.')
#   }
#   data <- matrix(ncol = ncol(tmpData), nrow = NrOfAllocationRows) # preallocate
#   timeStampRowNames = numeric(NrOfAllocationRows) - 1 # preallocate rownames vector. -1 to set default val other than 0
#   
#   #########################
#   # set up function formals + pb
#   if(!is.null(OnTheFlyFunctionName)){
#     funcFormals = formals(OnTheFlyFunctionName)
#     funcFormals[names(OnTheFlyParas)] = OnTheFlyParas
#     funcFormals$ToFile = FALSE
#     funcFormals$optLogFilePath = OnTheFlyOptLogFilePath
#     cat('\n  INFO: applying', OnTheFlyFunctionName, 'to', length(Seglist$utts), 'files\n')
#     
#     pb <- txtProgressBar(min = 0, max = length(Seglist$utts), style = 3)
#   }else{
#     if(verbose){
#       cat('\n  INFO: parsing', length(Seglist$utts), fileExt, 'files\n')
#       pb <- txtProgressBar(min = 0, max = length(Seglist$utts), style = 3)
#     }
#   }
#   
#   #########################
#   # LOOP OVER UTTS
#   curIndexStart = 1
#   for (i in 1:length(Seglist$utts)){
#     
#     fname = Seglist$utts[i]
#     
#     ################
#     #get data object
#     
#     if(!is.null(OnTheFlyFunctionName)){
#       setTxtProgressBar(pb, i)
#       funcFormals$listOfFiles = Seglist$utts[i]
#       curDObj = do.call(OnTheFlyFunctionName,funcFormals)
#     }else{
#       curDObj <- read.AsspDataObj(fname)
#       if(verbose){
#         setTxtProgressBar(pb, i)
#       }
#     }
#     
#     origFreq <- attr(curDObj, "origFreq")
#     
#     # set curStart+curEnd
#     curStart <- Seglist$start[i]
#     if(emusegs.type(Seglist) == 'event'){
#       curEnd <- Seglist$start[i]
#     }else{
#       curEnd <- Seglist$end[i]
#     }
#     
#     
#     fSampleRateInMS <- (1 / attr(curDObj, "sampleRate")) * 1000
#     fStartTime <- attr(curDObj, "startTime") * 1000
#     
#     # add one on if event to be able to capture in breakValues 
#     if(emusegs.type(Seglist) == 'event'){
#       if(npoints == 1 || is.null(npoints)){
#         timeStampSeq <- seq(fStartTime, curEnd + fSampleRateInMS, fSampleRateInMS)
#       }else{
#         timeStampSeq <- seq(fStartTime, curEnd + fSampleRateInMS * npoints, fSampleRateInMS)
#       }
#     }else{
#       timeStampSeq <- seq(fStartTime, curEnd, fSampleRateInMS)
#     }
#     ##################################################
#     # search for first element larger than start time
#     breakVal <- -1
#     for (j in 1:length(timeStampSeq)){
#       if (timeStampSeq[j] >= curStart){
#         breakVal <- j
#         break
#       }
#     }
#     
#     curStartDataIdx <- breakVal
#     curEndDataIdx <- length(timeStampSeq)
#     
#     
#     ################
#     # extract data
#     tmpData <- eval(parse(text = paste("curDObj$", colName, sep = "")))
#     
#     #############################################################
#     # set curIndexEnd dependant on if event/segment/cut/npoints
#     if(!is.null(cut) || emusegs.type(Seglist) == 'event'){
#       if(emusegs.type(Seglist) == 'event'){
#         cutTime = curStart
#         curEndDataIdx <- curStartDataIdx
#         curStartDataIdx = curStartDataIdx - 1 # last to elements are relevant -> move start to left
#       }else{
#         cutTime = curStart + (curEnd - curStart) * cut
#       }
#       
#       sampleTimes = timeStampSeq[curStartDataIdx:curEndDataIdx]
#       closestIdx = which.min(abs(sampleTimes - cutTime))
#       cutTimeSampleIdx = curStartDataIdx + closestIdx - 1
#       
#       if(is.null(npoints) || npoints == 1){
#         # reset data idxs
#         curStartDataIdx = curStartDataIdx + closestIdx - 1
#         curEndDataIdx = curStartDataIdx
#         curIndexEnd = curIndexStart
#       }else{
#         # reset data idx
#         halfNpoints = (npoints - 1) / 2 # -1 removes cutTimeSample
#         curStartDataIdx = cutTimeSampleIdx - floor(halfNpoints)
#         curEndDataIdx = cutTimeSampleIdx + ceiling(halfNpoints)
#         curIndexEnd = curIndexStart + npoints - 1
#       }
#       
#     }else{
#       # normal segments
#       curIndexEnd <- curIndexStart + curEndDataIdx - curStartDataIdx
#     }
#     # set index and ftime
#     index[i,] <- c(curIndexStart, curIndexEnd)
#     ftime[i,] <- c(timeStampSeq[curStartDataIdx], timeStampSeq[curEndDataIdx])
#     #############################
#     # calculate size of and create new data matrix
#     rowSeq <- seq(timeStampSeq[curStartDataIdx], timeStampSeq[curEndDataIdx], fSampleRateInMS) 
#     curData <- matrix(ncol = ncol(tmpData), nrow = length(rowSeq))
#     
#     # check if it is possible to extract curData 
#     if(curStartDataIdx > 0 && curEndDataIdx <= dim(tmpData)[1]){
#       curData[,] <- tmpData[curStartDataIdx:curEndDataIdx,]
#     }else{
#       entry= paste(Seglist[i,], collapse = " ")
#       stop('Can not extract following segmentlist entry: ', entry, ' start and/or end times out of bounds')
#     }
#     
#     ##############################
#     # Check if enough space (expand data matrix ifnecessary) 
#     # then append to data matrix 
#     if(length(data)<curIndexEnd){
#       if(verbose){
#         cat('\n  INFO: allocating more space in data matrix')
#       }
#       data = rbind(data, matrix(ncol = ncol(data), nrow = NrOfAllocationRows))
#       timeStampRowNames = c(timeStampRowNames, numeric(NrOfAllocationRows) - 1)
#     }
#     
#     data[curIndexStart:curIndexEnd,] = curData
#     timeStampRowNames[curIndexStart:curIndexEnd] <- rowSeq
#     curIndexStart <- curIndexEnd + 1
#     
#     curDObj = NULL
#     
#   }
#   
#   
#   ########################################
#   # remove superfluous NA vals from data
#   if(verbose){
#     cat('\n  INFO: removing superfluous NA vals from over-allocated data matrix\n')
#   }
#   data = data[complete.cases(data),]
#   data = as.matrix(data) # make sure it is a matrix to be able to set row names
#   timeStampRowNames = timeStampRowNames[timeStampRowNames != -1]
#   
#   if((!is.null(cut) && (npoints == 1 || is.null(npoints))) || (emusegs.type(Seglist) == 'event' && (npoints == 1 || is.null(npoints)))){
#     resObj = as.data.frame(data)
#     colnames(resObj) = paste(colName, seq(1:ncol(resObj)), sep = '')    
#   }else{
#     rownames(data) <- timeStampRowNames
#     colnames(data) <- paste("T", 1:ncol(data), sep = "")
#     ########################################
#     #convert data, index, ftime to trackdata
#     resObj <- as.trackdata(data, index=index, ftime, FileExtAndTrackName)
#     
#     if(any(colName %in% c("dft", "css", "lps", "cep"))){
#       if(!is.null(origFreq)){
#         cat('\n  INFO: adding fs attribute to trackdata$data fields')
#         attr(resObj$data, "fs") <- seq(0, origFreq/2, length=ncol(resObj$data))
#         class(resObj$data) <- c(class(resObj$data), "spectral")
#       }else{
#         stop("no origFreq entry in spectral data file!")
#       }
#     }
#   }
#   
#   # close progress bar if open
#   if(!is.null(OnTheFlyFunctionName) && !verbose){
#     close(pb)
#   }
#   
#   #print(resObj)
#   return(resObj)
#   
# }


# FOR DEVELOPMENT
#system.time(emu.track2(new.sWithExpUtts[1:200,], 'dft:dft', path2db, NrOfAllocationRows = 100000))
#td = emu.track2(new.sWithExpUtts, 'dft:dft', path2db)
#n = emu::emu.query('ae','*','Phonetic=n')
#emu.track2(n, 'fms:fm', '~/emuDBs/ae/')

#emu::emu.track(n, 'fm', cut=.1, npoints = 3)

#t = emu::emu.query('ae','*','Tone=H*')
#emu::emu.track(t, 'fm', npoints=3)

###########################

#tdnew = emu.track2(t, 'fms:fm', path2db, npoints = 3)

#tdnew = emu.track2(n, 'pit:pitch', path2db, OnTheFlyFunctionName = 'mhsF0', verbose=F)
