require(stringr)


## Parser for Praat TextGrid files
## 
## @param textGridCon TextGrid file connection
## @param sampleRate sample rate of correponding signal file
## @param encoding text encoding (default UTF-8)
## @return an annoation object
## @author Klaus Jaensch
## @import stringr
## @keywords emuSX TextGrid Praat Emu
## 
parse.textgrid <- function(textGridCon=NULL, sampleRate,encoding="UTF-8") {
  FILE_TYPE_KEY="File type"
  OBJECT_CLASS_KEY="Object class"
  TIERS_SIZE_KEY="size"
  TIER_ITEM_KEY="item"
  NAME_KEY="name"
  INTERVALS_KEY="intervals"
  POINTS_KEY="points"
  XMIN_KEY="xmin"
  XMAX_KEY="xmax"
  TEXT_KEY="text"
  TIME_KEY="time"
  
  FILE_TYPE_VAL_OO_TEXTFILE="ooTextFile"
  OBJECT_CLASS_VAL_TEXTGRID="TextGrid"
  TIER_CLASS_VAL_INTERVAL="IntervalTier"
  TIER_CLASS_VAL_TEXT="TextTier"
  
  fileType=NULL
  objectClass=NULL
  hasTiers=FALSE
  tiersCount=NULL
  currentTier=NULL
  currentTierClass=NULL
  currentTierName=NULL
  currentTierSize=NULL
  levels=list()
  
  if(is.null(textGridCon)) {
    stop("Argument textGridCon must not be NULL\n")
  }
  if(sampleRate <=0 ){
    stop("Samplerate must be greater than zero\n")
  }
  
  # read
  tg = try(readLines(textGridCon))
  if(class(tg) == "try-error") {
    stop("read.TextGrid: cannot read from file ", textGridCon)
  }
  
  for(line in tg){
    trimmedLine=str_trim(line)
    #cat("Trimmed line: ",trimmedLine,"\n")
    if(is.null(fileType)){
      p=parse.line.to.key.value(line,doubleQuoted=TRUE)
      if(! is.null(p)){
        if(p[1]==FILE_TYPE_KEY){
          #cat("Found file type: ",p[2],"\n")
          fileType=p[2]
        }
      }
    }else{
      if(is.null(objectClass)){
        p=parse.line.to.key.value(line,doubleQuoted=TRUE)
        if(! is.null(p)){
          if(p[1]==OBJECT_CLASS_KEY){
            #cat("Found object class: ",p[2],"\n")
            objectClass=p[2]
          }
        }
      }else{
        # we have file type and object class
        
        if((fileType==FILE_TYPE_VAL_OO_TEXTFILE) && (objectClass==OBJECT_CLASS_VAL_TEXTGRID)){
          
          #if(!hasTiers){
          #  Property p=parseProperty(line,"\\s+", false);
          #  hasTiers=(p!=null && p.key.equals("tiers?") && p.value.equals("<exists>"));
          #}else{
          if(is.null(tiersCount)){
            
            p=parse.line.to.key.value(line)
            if((!is.null(p)) && (p[1]=='size')){
              tiersCount=p[2]
              
            }
          }else{
            ## we have tiersCount tiers
            if(length(grep("^item",trimmedLine))==1){
              
              tierIndexStr=sub('item\\s*','',trimmedLine);
              #cat("Tier indxstr: ",tierIndexStr,"\n")
              tierIndexStr=sub('\\s*:$','',tierIndexStr);
              if(length(grep('\\[\\s*[0-9]+\\s*\\]',tierIndexStr))==1){
                tierIndexStr=sub('\\[\\s*','',tierIndexStr);
                tierIndexStr=sub('\\s*\\]','',tierIndexStr);
                
                tierIndex=tierIndexStr;
                #cat("Tier indx:",tierIndex,"\n")
                #cat("Tiers1: ",length(tiers),"\n")
                if(!is.null(currentTier)){
                  #cat("Tiers2: ",length(tiers),"\n")
                  # TODO use tier name !!!
                  levels[[currentTier[['name']]]]=currentTier
                }
                currentTier=create.bundle.level(sampleRate=sampleRate)
                #tiers[[length(tiers)+1]] <- currentTier                       
                #    currentTier=new Tier();
                #    
                currentTierClass=NULL;
                currentTierName=NULL;
                currentTierSize=NULL;
                currentSegment=NULL;
                currentSegmentIndex=NULL;
                currentSegmentStart=NULL;
                currentSegmentDur=NULL;
                currentSegmentLabel=NULL;
                currentMark=NULL;
                currentPointIndex=NULL;
                currentPointSample=NULL;
                currentPointLabel=NULL;
                #    if(DEBUG)System.out.println("Tier index: "+tierIndex);
              }
            }else {
              if(is.null(currentTierClass)){
                p=parse.line.to.key.value(line,doubleQuoted=TRUE)
                if((! is.null(p)) && ('class' == p[1])){
                  currentTierClass=p[2];
                  if(currentTierClass==TIER_CLASS_VAL_INTERVAL){
                    currentTier$type='SEGMENT';
                    #annotation.getTiers().add(currentTier);
                    
                  }else if(currentTierClass==TIER_CLASS_VAL_TEXT){
                    currentTier$type='EVENT';
                    #annotation.getTiers().add(currentTier);
                    
                  }else{
                    stop("TextGrid tiers of class \"",currentTierClass,"\" not supported!");
                  }
                }
              }
              if(is.null(currentTierName)){
                p=parse.line.to.key.value(line,doubleQuoted=TRUE)
                if((! is.null(p)) && ('name' == p[1])){
                  currentTierName=p[2];
                  currentTier$name=currentTierName;
                  #cat("Tier name:",currentTierName,currentTier$TierName,tiers[[length(tiers)]]$TierName,"\n")
                  
                }
              }
              if(! is.null(currentTierClass)){
                if(currentTierClass==TIER_CLASS_VAL_INTERVAL){
                  #currentTier.setType(Tier.Type.INTERVAL);
                  #cat("Interval tier check line 2 : ",trimmedLine,"\n")
                  # find size (and other properties)
                  if((is.null(currentTierSize)) && (length(grep('^intervals[[:space:]]*:.*',trimmedLine))==1)){
                    
                    intervalsPropertyStr=str_trim(sub('^intervals[[:space:]]*:','',trimmedLine))
                    #cat("Intervals prop str: ",intervalsPropertyStr,"\n")
                    intervalsProperty=parse.line.to.key.value(intervalsPropertyStr);
                    if((!is.null(intervalsProperty)) && (intervalsProperty[1]=='size')){
                      currentTierSize=intervalsProperty[2]
                      # cat("intervals: size=",currentTierSize,"\n");
                      
                    }
                  }
                  #cat("grep('intervals[[:space:]]*[[][[:space:]]*[0-9]+[[:space:]]*[]][[:space:]]*[:][[:space:]]*'",trimmedLine,"\n");
                  if(length(grep('intervals[[:space:]]*[[][[:space:]]*[0-9]+[[:space:]]*[]][[:space:]]*[:][[:space:]]*',trimmedLine))==1){
                    
                    #cat("Interval !!\n");
                    segmentIndexStr=sub("intervals[[:space:]]*[[][[:space:]]*","",trimmedLine);
                    segmentIndexStr=sub("[[:space:]]*[]][[:space:]]*[:][[:space:]]*","",segmentIndexStr);
                    currentElementIndex=segmentIndexStr;
                    
                    #currentSegment=emuSX.annotation.model.IntervalItem()
                    
                    
                    currentSegmentIndex=segmentIndexStr;
                    currentSegmentStart=NULL;
                    currentSegmentEnd=NULL;
                    currentSegmentLabel=NULL;
                    
                    #cat("Events: ",length(currentTier$events),"\n")
                    #currentSegment.setSampleRate(sampleRate);
                    #currentTier.getSegments().add(currentSegment);
                    #currentSegment.setTier(currentTier);
                    #if(DEBUG)System.out.println("Interval: "+currentElementIndex);
                    
                  }else{
                    p=parse.line.to.key.value(line,doubleQuoted=TRUE)
                    if((!is.null(p)) && (!is.null(currentSegmentIndex))){
                      if(p[1] == "xmin"){
                        minTimeStr=p[2]
                        minTime=as(minTimeStr,"numeric")
                        startSample=round(minTime*sampleRate)
                        currentSegmentStart=startSample
                        #long minFrames=timeToFrames(minTime);
                        #currentSegment.setBegin(minFrames);
                        #if(DEBUG)System.out.println("Segment: "+currentSegment);
                      }else if(p[1]=="xmax"){
                        maxTimeStr=p[2];
                        #long maxFrames=timeToFrames(maxTime);
                        #currentSegment.setEnd(maxFrames);
                        #if(DEBUG)System.out.println("Segment: "+currentSegment);
                        maxTime=as(maxTimeStr,"numeric")
                        currentSegmentEnd=round(maxTime*sampleRate)
                        
                        
                      }else if(p[1]=="text"){
                        #currentSegment.setLabel(p.value);
                        #if(DEBUG)System.out.println("Segment: "+currentSegment);
                        label=p[2];
                        currentSegmentLabel=label;
                        #cat("Found label: ",label,"\n")
                      }
                      
                      if(!is.null(currentSegmentIndex) && 
                           !is.null(currentSegmentStart) &&
                           !is.null(currentSegmentEnd) &&
                           !is.null(currentSegmentLabel)){
                        #cat("New segment\n");
                        sampleDur=currentSegmentEnd-currentSegmentStart
                        labels=list(name=currentTierName,value=currentSegmentLabel)
                        currentSegment=create.interval.item(sampleStart=currentSegmentStart,sampleDur=sampleDur,labels=labels);
                        currentTier$items[[length(currentTier$items)+1]] <- currentSegment
                        
                        currentSegment=NULL;
                        currentSegmentIndex=NULL;
                        currentSegmentStart=NULL;
                        currentSegmentDur=NULL;
                      }
                      
                    }
                  }
                  
                }else if(currentTierClass==TIER_CLASS_VAL_TEXT){
                  #currentTier.setType(Tier.Type.POINT);
                  
                  # find size (and other properties)
                  if((is.null(currentTierSize)) && (length(grep('^points[[:space:]]*[:].*',trimmedLine))==1)){
                    
                    intervalsPropertyStr=str_trim(sub('^points[[:space:]]*[:]','',trimmedLine))
                    #cat("Ivp:",intervalsPropertyStr,"\n")
                    intervalsProperty=parse.line.to.key.value(intervalsPropertyStr);
                    if((!is.null(intervalsProperty)) && (intervalsProperty[1]=='size')){
                      currentTierSize=intervalsProperty[2]
                      #cat("points: size=",currentTierSize,"\n");
                      
                    }
                  }
                  if(length(grep("points[[:space:]]*[[][[:space:]]*[0-9]+[[:space:]]*[]][[:space:]]*[:][[:space:]]*",trimmedLine))==1){
                    pointIndexStr=sub("points[[:space:]]*[[][[:space:]]*","",trimmedLine);
                    pointIndexStr=sub("[[:space:]]*[]][[:space:]]*[:][[:space:]]*","",pointIndexStr);
                    currentPointIndex=as.integer(pointIndexStr)
                    currentElementIndex=currentPointIndex
                    currentPointLabel=NULL;
                    currentPointSample=NULL;
                  }else{
                    #cat("inside point: \n")
                    p=parse.line.to.key.value(line,doubleQuoted=TRUE)
                    if((!is.null(p)) && (!is.null(currentPointIndex))){
                      if(p[1]=="time"){
                        timePointStr=p[2];
                        timePoint=as(timePointStr,"numeric")
                        samplePoint=round(timePoint*sampleRate)
                        currentPointSample=samplePoint
                       #cat("point sample: ",currentPointSample,"\n")
                        #    long frames=timeToFrames(time);
                        #    currentMark.setPosition(frames);
                      }else if(p[1]=="mark"){
                        currentPointLabel=p[2]
                       # cat("point label: ",currentPointLabel,"\n")
                      }else if(p[1]=="text"){
                        currentPointLabel=p[2]
                      }
                    }
                    if(!is.null(currentPointIndex) && 
                         !is.null(currentPointSample) &&
                         !is.null(currentPointLabel)){
                      
                      labels=list(name=currentTierName,value=currentPointLabel)
                    
                      currentPoint=create.event.item(samplePoint=currentPointSample,labels=labels)
                      currentTier$items[[length(currentTier$items)+1]]=currentPoint
                      
                      currentPointIndex=NULL;
                      currentPointLabel=NULL;
                      currentPointSample=NULL;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  if(!is.null(currentTier)){
    levels[[currentTier[['name']]]] <- currentTier
  }
  if(inherits(textGridCon,"connection")){
    close(textGridCon)
  }
  return(levels)
}