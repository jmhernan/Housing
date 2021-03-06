% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/condition_counts.R
\name{condition_counts}
\alias{condition_counts}
\alias{count_acute}
\alias{count_chronic}
\title{Count the number of events/population with condition by desired grouping}
\usage{
count_acute(df, year, group_var = quos(agency_new), age_var = NULL,
  len_var = NULL, event = NULL, event_year = event_year,
  unit = NULL, person = FALSE, birth = NULL)

count_chronic(df_chronic = chronic, df_pop = chronic_pop,
  condition = NULL, year = 12)
}
\arguments{
\item{df}{A data frame containing health event/condition data.}

\item{year}{The calendar year (2 digits) of interest.}

\item{group_var}{A set of variables to group counts by. Default is PH agency.
Must be set as a quosure (use quos(<group1>, <group2>)). Use age_var and 
len_var to add age or length of time in housing to the grouping.}

\item{age_var}{Denotes the suffix to use when adding pre-calculated age 
fields to the grouping variables. Most likely to be '_grp'. Should be a 
string. Currently hard coded to attach to ageXX where XX is the year.}

\item{len_var}{Denotes the suffix to use when adding pre-calculated length 
fields to the grouping variables. Most likely to be '_grp'. Should be a 
string. Currently hard coded to attach to ageXX where XX is the year.}

\item{event}{The acute health event of interest. Should match a field name in
the df.}

\item{event_year}{The field that identifies which calendar year the event 
occurred in (acute events only).}

\item{unit}{A named variable that determines the unit to count over. 
Default unit of analysis is pid2 (individuals) but pid should be used with 
data not matched to Medicaid. The other option is hhold_id_new for households.}

\item{person}{A binary flag to indicator whether all acute events should be
counted or just one per person in the time period.}

\item{birth}{A named variable that determines which date of birth field to 
use when calculating age (normally dob_c or dob_h but can also use 
hh_dob_m6 if calculating age at the household level). Currently only needed 
if using a well-child indicator (could be extended to calculate age for a
non-calendar year period though).}
}
\description{
These functions count the number of acute events/people with conditions for
a given grouping and calendar year. It is currently specific to the joined
Medicaid/housing data sets but could be generalized to other data.
Can also be made to work with other time periods, but age and other demogs
would need to be recalculated in the function.
}
\examples{
\dontrun{
popcount(pha_longitudinal)
popcount(pha_longitudinal, group_var = quos(agency_new, major_prog),
agency = "kcha", unit = hhold_id_new)
popcount(pha_longitudinal, yearmin = 2014, yearmax = 2016, period = "month")
}

}
