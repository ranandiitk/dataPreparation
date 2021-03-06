#######################################################################################
############################# Set col as numeric ######################################
#######################################################################################
#' Set columns as numeric
#' 
#' Set as numeric a character column (or a list of columns) from a data.table.
#' @param dataSet Matrix, data.frame or data.table
#' @param cols List of column(s) name(s) of dataSet to transform into numerics
#' @param stripString should I change "," to "." in the string? (logical, default to FALSE) 
#' If set to TRUE, computation will be a bit longer
#' @param verbose Should the function log (logical, default to TRUE)
#' @return  dataSet (as a \code{\link{data.table}}), with specified columns set as numeric. 
#' @examples
#' # Build a fake data.table
#' dataSet <- data.frame(charCol1 = c("1", "2", "3"), 
#' 						 charCol2 = c("4", "5", "6"))
#'
#' # Set charCol1 and charCol2 as numeric
#' dataSet <- setColAsNumeric(dataSet, cols = c("charCol1", "charCol2"))
#'
#' # Using strip string when spaces or wrong decimal separator is used
#' dataSet <- data.frame(charCol1 = c("1", "2", "3"), 
#'                       charCol2 = c("4, 1", "5, 2", "6, 3"))
#'
#' # Set charCol1 and charCol2 as numeric
#' setColAsNumeric(dataSet, cols = c("charCol1", "charCol2")) 
#' # generate mistakes
#' setColAsNumeric(dataSet, cols = c("charCol1", "charCol2"), stripString = TRUE) 
#' # Doesn't generate any mistake (but is a bit slower)
#' @import data.table
#' @export
setColAsNumeric <- function(dataSet, cols, stripString = FALSE, verbose = TRUE){ 
  ## Working environement
  function_name <- "setColAsNumeric"
  
  ## Sanity check
  dataSet <- checkAndReturnDataTable(dataSet)
  cols <- real_cols(dataSet, cols, function_name, types = c("character"))
  is.verbose(verbose)
  
  ## Initialization
  
  ## Computation
  if (verbose){
    printl(function_name, ": I will set some columns as numeric")
    pb <- initPB(function_name, cols)
  }
  for (col in cols){
    if (verbose){
      printl(function_name, ": I am doing the column ", col, ".")
      options(warn = -1) # if verbose, disable warning, it will  be logged
    }
    n_na_init <- sum(is.na(dataSet[[col]]))
    if (stripString){
      set(dataSet, NULL, col, as.numericStrip(dataSet[[col]]))
    }
    else{
      set(dataSet, NULL, col, as.numeric(dataSet[[col]])) 
    }
    if (verbose){
      printl(function_name, ": ", sum(is.na(dataSet[[col]])) - n_na_init, 
             " NA have been created due to transformation to numeric.")
    } 
    if (verbose){
      setPB(pb)
    }
  }
  if(verbose){
    # reset warnings
    options(warn = 0)
  }
  
  ## Wrapp-up
  return(dataSet)
}


#######################################################################################
############################# Set col as character ####################################
#######################################################################################
#' Set columns as character
#'
#' Set as character a column (or a list of columns) from a data.table.
#' @param dataSet Matrix, data.frame or data.table
#' @param cols List of column(s) name(s) of dataSet to transform into characters. To transform 
#' all columns, set it to "auto". (characters, default to "auto")
#' @param verbose Should the function log (logical, default to TRUE)
#' @return  dataSet (as a \code{\link{data.table}}), with specified columns set as character. 
#' @examples
#' # Build a fake data.frame
#' dataSet <- data.frame(numCol = c(1, 2, 3), factorCol = as.factor(c("a", "b", "c")))
#'
#' # Set numCol and factorCol as character
#' dataSet <- setColAsCharacter(dataSet, cols = c("numCol", "factorCol"))
#' @import data.table
#' @export
setColAsCharacter <- function(dataSet, cols = "auto", verbose = TRUE){ 
  ## Working environement
  function_name <- "setColAsCharacter"
  
  ## Sanity check
  dataSet <- checkAndReturnDataTable(dataSet)
  is.verbose(verbose)
  cols <- real_cols(dataSet, cols, function_name)
  
  ## Initalization
  if (verbose){
    printl(function_name, ": I will set some columns as character")
    pb <- initPB(function_name, cols)
  }
  
  ## Computation
  for (col in cols){
    if (verbose){
      printl(function_name, ": I am doing the column ", col, ".")
    }
    if ( (is.character(dataSet[[col]])) & verbose){
      printl(function_name, ": ", col, " is a character, i do nothing.")
    }
    if (! (is.character(dataSet[[col]]))){
      set(dataSet, NULL, col, as.character(dataSet[[col]])) 
    }
    if (verbose){
      setPB(pb)
    }
  }
  return(dataSet)
}

#######################################################################################
############################# Set col as Date #########################################
#######################################################################################
#' Set columns as POSIXct 
#'
#' Set as POSIXct a character column (or a list of columns) from a data.table.
#' @param dataSet Matrix, data.frame or data.table
#' @param cols List of column(s) name(s) of dataSet to transform into dates
#' @param format Date's format (function will be faster if the format is provided) 
#' (character, default to NULL).\cr
#' For timestamps, format need to be provided ("s" or "ms" or second or millisecond timestamps)
#' @param verbose Should the function log (logical, default to TRUE)
#' @details 
#' setColAsDate is way faster when format is provided. If you want to identify dates and format
#' automatically, have a look to \code{\link{findAndTransformDates}}. \cr
#' If input column is a factor, it will be returned as a POSIXct column
#' @return \code{dataSet}(as a \code{\link{data.table}}), with specified columns set as Date. 
#' If the transformation generated only NA, the column is set back to its original value.
#' @examples
#' # Lets build a dataSet set
#' dataSet <- data.frame(ID = 1:5, 
#'                   date1 = c("2015-01-01", "2016-01-01", "2015-09-01", "2015-03-01", "2015-01-31"), 
#'                   date2 = c("2015_01_01", "2016_01_01", "2015_09_01", "2015_03_01", "2015_01_31")
#'                   )
#'
#' # Using setColAsDate for date2
#' data_transformed <- setColAsDate(dataSet,cols = "date2", format = "%Y_%m_%d")
#' 
#' # Control the results
#' lapply(data_transformed,class)
#' 
#' # It also works with timestamps
#' dataSet <- data.frame( time_stamp = c(1483225200, 1485990000, 1488495600))
#' setColAsDate(dataSet, cols = "time_stamp", format = "s")
#' @import data.table
#' @importFrom lubridate parse_date_time 
#' @importFrom stringr str_replace_all
#' @export
setColAsDate <- function(dataSet, cols, format = NULL, verbose = TRUE){
  ## Working environment
  function_name <- "setColAsDate"
  
  ## Sanity check
  dataSet <- checkAndReturnDataTable(dataSet)
  is.verbose(verbose)
  cols <- real_cols(dataSet, cols, function_name, types = c("character", "factor", "numeric", "integer"))
  
  ## Initialization
  start_time <- proc.time()
  if (verbose){
    printl(function_name, ": I will set some columns as Date.")
    pb <- initPB(function_name, cols)
  }
  n_transformed <- length(cols)
  
  ## Computation
  for (col in cols){
    if (verbose){
      printl(function_name, ": I am doing the column ", col, ".")
      options(warn = -1) # if verbose, disable warning, it will  be logged
    }
    # Creating data sample to transform
    if (is.factor(dataSet[[col]])){
      data_sample <- levels(dataSet[[col]])[dataSet[[col]]]
    }
    else{
      data_sample <- dataSet[[col]]
    }
    n_na_init <- sum(is.na(data_sample))
    result <- data_sample # Initialize it to no changes. To-do this shouldn't be necessay
    if (is.character(data_sample)){
      # If format is NULL, we let R determine the format
      if (is.null(format)){
        # If format is not given, search for it. 
        format_tmp <- identifyDates(dataSet[, c(col), with = FALSE], n_test = min(30, nrow(dataSet)))$formats
        if (!is.null(format_tmp)){
          result <- as.POSIXct(data_sample, format = format_tmp)
        }
        else{
          printl(function_name, ":, ", col, " doesn't seem to be a date, if it really is please provide format.")
        }
      }
      # If it isn't NULL
      if (!is.null(format)){
        # it is faster if it's a format accepted by parse_date_time, so we check that
        format4parse_date_time <- formatForparse_date_time()
        format_tmp <- str_replace_all(format, "[[:punct:]]", "")
        if (format_tmp %in% format4parse_date_time){
          result <- parse_date_time(data_sample, orders = format_tmp)
        }
        else{
          result <- as.POSIXct(data_sample, format = format)
        }
      }
    }
    else if (is.numeric(data_sample) & !is.null(format)){
      if (format == "s"){
        result <- as.POSIXct(dataSet[[col]], origin = "1970-01-01 00:00:00")
      }
      if (format == "ms"){
        result <- as.POSIXct(dataSet[[col]] / 1000, origin = "1970-01-01 00:00:00")
      }
    }
    else{
      options(warn = 0)
      warning(paste0(function_name, ": I can't handle ", col, ", please see documentation."))
      options(warn = -1)
      n_transformed <- n_transformed - 1
      next()
    }
    n_na_end <- sum(is.na(result))
    if (verbose){
      printl(function_name, ":", n_na_end - n_na_init, " NA have been created due to transformation to Date.")
    }
    # If we generated only NA and format wasn't provide, we shouldn't have changer it so we set it bakck to char
    if (n_na_end == nrow(dataSet) & n_na_init < nrow(dataSet)){
      if (verbose){
        printl(function_name, ":", " Since i generated only NAs i set ", col, " as it was before.")
      }
      result <- data_sample
    }
    # Assign result
    set(dataSet, NULL, col, result)  
    if (verbose){
      # reset warnings
      options(warn = 0)
      setPB(pb)
    }
  }
  ## Wrapp-up
  if (verbose){
    printl(function_name, ": it took me: ", round((proc.time() - start_time)[[3]], 2), 
           "s to transform ", n_transformed, " column(s) to Dates.")
  }
  return(dataSet)
}


############################################################################################################
########################################### charToFactorOrLogical ##########################################
############################################################################################################
#' Set columns as factor
#' 
#' Set columns as factor and control number of unique element, to avoid having too large factors.
#' @param dataSet Matrix, data.frame or data.table
#' @param cols List of column(s) name(s) of dataSet to transform into factor. To transform all columns
#'  set it to "auto", (characters, default to auto).
#' @param n_levels Max number of levels for factor (integer, default to 53) 
#' set it to -1 to disable control.
#' @param verbose Should the function log (logical, default to TRUE)
#' @details 
#' Control number of levels will help you to distinguish true categorical columns from just characters 
#' that should be handled in another way.
#' @return \code{dataSet}(as a \code{\link{data.table}}), with specified columns set as factor or logical.
#' @examples
#' # Load messy_adult
#' data("messy_adult")
#' 
#' # we wil change education
#' messy_adult <- setColAsFactor(messy_adult, cols = "education")
#' 
#' sapply(messy_adult[, .(education)], class)
#' # education is now a factor
#' @export
setColAsFactor <- function(dataSet, cols = "auto", n_levels = 53, verbose = TRUE){
  ## Working environment
  function_name <- "setColAsFactor"
  
  ## Sanity check
  dataSet <- checkAndReturnDataTable(dataSet)
  if (!is.numeric(n_levels)){stop(paste0(function_name, ": n_levels should be an integer."))}
  cols <- real_cols(dataSet, cols, function_name)
  is.verbose(verbose)
  
  ## Initialization
  if (verbose){
    printl(function_name, ": I will set some columns to factor.")
    pb <- initPB(function_name, cols)
  }
  n_transformed <- 0
  start_time <- proc.time()
  
  ## Computation
  for (col in cols){ 
    if (verbose){
      printl(function_name, ": I am doing the column ", col, ".")
    }
    if (n_levels != -1){
      if (fastMaxNbElt(dataSet[[col]], n_levels)){
        set(dataSet, NULL, col, as.factor(dataSet[[col]]))
        n_transformed <- n_transformed + 1
      }
      else{
        printl(function_name, ": ", col, " has more than ", n_levels, " values, i don't transform it.")
      }  
    }
    else{
      set(dataSet, NULL, col, as.factor(dataSet[[col]]))
    }
    if (verbose){
      setPB(pb)
    }
  }
  if (verbose){
    printl(function_name, ": it took me: ", round((proc.time() - start_time)[[3]], 2), 
           "s to transform ", n_transformed, " column(s) to factor.")
  }
  ## Wrapp up
  return(dataSet)
}
