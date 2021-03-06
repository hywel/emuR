require(stringr)


## Get first position of character in a string from given position
## 
## @param string string to search in
## @param char character to search
## @param pos start position
## @param literalQuote optional quote character to quote literal strings
## @return position in string or -1 if not found or pos outside string constraints
## @import stringr
get.char.position <- function(string,char,pos=1,literalQuote=NULL){
  
  strLen=nchar(string)
 
  us=pos:strLen
  inLiteral=FALSE
  for(c in us){
    if(c>strLen){
      return(-1)
    }
    ch=substr(string,c,c)
    if(!is.null(literalQuote)){
      if(ch==literalQuote){
        inLiteral=!inLiteral
      }
    }
    if(!inLiteral && ch==char){
      return(c)
    }
    
  }
  return(-1)
}

## Get first position of string in a string from given position
## 
## @param string string to search in
## @param searchStr string to search
## @param pos start position
## @param literalQuote optional quote character to quote literal strings
## @return position in string or -1 if not found or pos outside string constraints
## @import stringr
get.string.position <- function(string,searchStr,pos=1,literalQuote=NULL){
  
  strLen=nchar(string)
  searchStrLen=nchar(searchStr)
  us=pos:strLen-searchStrLen+1
  inLiteral=FALSE
  for(c in us){
    if(c>strLen){
      return(-1)
    }
    ch=substr(string,c,c)
    if(!is.null(literalQuote)){
      if(ch==literalQuote){
        inLiteral=!inLiteral
      }
    }
    
    sstr=substr(string,c,c+searchStrLen-1)
    if(!inLiteral && sstr==searchStr){
      return(c)
    }
    
  }
  return(-1)
}


## Get last position of character in a string from given position backwards
## 
## @param string string to search in
## @param char character to search
## @param pos start position
## @param literalQuote optional quote character to quote literal strings
## @return position in string or -1 if not found or pos outside string constraints
## @import stringr
get.last.char.position <- function(string,char,pos=nchar(string),literalQuote=NULL){
  strLen=nchar(string)
  
  us=pos:1
  inLiteral=FALSE
  for(c in us){
   
    ch=substr(string,c,c)
    if(!is.null(literalQuote)){
      if(ch==literalQuote){
        inLiteral=!inLiteral
      }
    }
    if(!inLiteral && ch==char){
      return(c)
    }
    
  }
  return(-1)
}

## Get first position of character in a string from given position
## 
## @param string string to search in
## @param search string to search
## @param pos start position
## @param literalQuote character to quote literal strings
## @param bracket two-dim vector char concatenating open and close bracket (e.g. c('[',']'))
## @return position in string or -1 if not found or pos outside string constraints
## @import stringr
get.string.position.outside.brackets <- function(string,search,pos=1,literalQuote=NULL,bracket=NULL){
  
  strLen=nchar(string)
  sLen=nchar(search)
  us=pos:strLen
  inLiteral=FALSE
  inBracketLvl=0
  for(c in us){
    if(c>strLen){
      return(-1)
    }
    ch=substr(string,c,c)
    if(!is.null(literalQuote)){
      if(ch==literalQuote){
        inLiteral=!inLiteral
      }
    }
    if(!inLiteral && !is.null(bracket)){
      if(ch==bracket[1]){
        inBracketLvl=inBracketLvl+1
      }else if(ch==bracket[2]){
        inBracketLvl=inBracketLvl-1
      }
      if(inBracketLvl<0){
        stop("Syntax error: Close bracket ",bracket[2]," without open bracket ",bracket[1],"\n")
      }
    }
    if(!inLiteral && inBracketLvl==0){
      sStr=substr(string,c,c+sLen-1)
      if(sStr==search){
        return(c)
      }
    }
    
  }
  return(-1)
}

## Parse line to key value pair
## @param line line
## @param separator separator char
## @param doubleQuoted TRUE if expecting double quoted value
## @param initialTrim remove leading+trailing whitespaces before procceeding (default=TRUE)
## @return character vector conating key and value
## @import stringr
parse.line.to.key.value=function(line,separator='=',doubleQuoted=FALSE, initialTrim=TRUE){ 
  if(initialTrim){
    line=str_trim(line)
  }
  #cat("Trimmed line: ",line,"\n",sep='');
  #eqSignI=str_locate(line,'=')[1]
  # cat("Pos: ",eqSignI,"\n")
  eqSignI=get.char.position(line,separator)
  if(eqSignI==-1){
    return(NULL)
  }
  left=str_sub(line,end=eqSignI-1)
  key=str_trim(left)
  right=str_sub(line,start=eqSignI+1)
  value=str_trim(right)
  if(doubleQuoted){
    value=sub('^\"','',value);
    value=sub('\"$','',value);
  }
  return(c(key,value))
}