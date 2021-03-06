% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{jobkeeper_sa2}
\alias{jobkeeper_sa2}
\title{JobKeeper data by SA2}
\format{
A dataframe with 4 variables
\describe{
\item{sa2_main_2016}{Statistical Area 2 Code}
\item{date}{Date}
\item{indicator}{Jobkeeper applications, Total businesses, Jobkeeper proportion}
\item{value}{Value}
}
}
\source{
\url{https://treasury.gov.au/coronavirus/jobkeeper/data}
}
\usage{
jobkeeper_sa2
}
\description{
This dataset uses treasury estimates of JobKeeper applications by
postcode, and reconciles that to a statistical area measure instead.
Conversion is done through apportioning businesses via meshblocks.
}
\keyword{datasets}
