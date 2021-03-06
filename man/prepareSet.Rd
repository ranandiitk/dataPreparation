% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prepareSet.R
\name{prepareSet}
\alias{prepareSet}
\title{Preparation pipeline}
\usage{
prepareSet(dataSet, finalForm = "data.table", verbose = TRUE, ...)
}
\arguments{
\item{dataSet}{Matrix, data.frame or data.table}

\item{finalForm}{"data.table" or "numerical_matrix" (default to data.table)}

\item{verbose}{Should the algorithm talk? (logical, default to TRUE)}

\item{...}{Additional parameters to tune pipeline (see details)}
}
\value{
A data.table or a numerical matrix (according to \code{finalForm}). \cr
It will perform the following steps:
\itemize{
  \item Correct set: unfactor factor with many values, id dates and numeric that are hiden in character
  \item Transform set: compute differences between every date, transform dates into factors, generate 
     features from character..., if \code{key} is provided, will perform aggregate according to this \code{key}
  \item Filter set: filter constant, in double or bijection variables. If `digits` is provided, 
     will round numeric
  \item Handle NA: will perform \code{\link{fastHandleNa}})
  \item Shape set: will put the result in asked shape (\code{finalForm}) with acceptable columns format.
}
}
\description{
Full pipeline for preparing your dataSet set.
}
\details{
Additional arguments are available to tune pipeline: 
\itemize{
  \item \code{key} Name of a column of dataSet according to which dataSet should be aggregated 
     (character)
  \item \code{analysisDate} A date at which the dataSet should be aggregated 
     (differences between every date and analysisDate will be computed) (Date)
  \item \code{n_unfactor} Number of max value in a facotr, set it to -1 to disable 
  \code{\link{unFactor}} function.  (numeric, default to 53)
  \item \code{digits} The number of digits after comma (optional, numeric, if set will perform 
     \code{\link{fastRound}})
  \item \code{dateFormats} List of format of Dates in dataSet (list of characters)
  \item \code{name_separator} character to separate parts of new column names (character, default to ".")
  \item \code{functions}  Aggregation functions for numeric columns, see \code{\link{aggregateByKey}} (list of functions)
  \item \code{factor_date_type} Aggregation level to factorize date (see 
     \code{\link{generateFactorFromDate}}) (character, default to "yearmonth")
}
}
\examples{
# Load ugly set
\dontrun{
data(messy_adult)

# Have a look to set
head(messy_adult)

# Compute full pipeline
clean_adult <- prepareSet(messy_adult)

# With a reference date
adult_agg <- prepareSet(messy_adult, analysisDate = as.Date("2017-01-01"))

# Add aggregation by country
adult_agg <- prepareSet(messy_adult, analysisDate = as.Date("2017-01-01"), key = "country")

# With some new aggregation functions
power <- function(x){sum(x^2)}
adult_agg <- prepareSet(messy_adult, analysisDate = as.Date("2017-01-01"), key = "country", 
                        functions = c(min, max, mean, power))
}
# "##NOT RUN:" mean that this example hasn't been run on CRAN since its long. But you can run it!
}
