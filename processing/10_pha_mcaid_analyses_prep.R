###############################################################################
# OVERVIEW:
# Code to create a cleaned person table from the combined 
# King County Housing Authority and Seattle Housing Authority data sets
# Aim is to have a single row per contiguous time in a house per person
#
# STEPS:
# 01 - Process raw KCHA data and load to SQL database
# 02 - Process raw SHA data and load to SQL database
# 03 - Bring in individual PHA datasets and combine into a single file
# 04 - Deduplicate data and tidy up via matching process
# 05 - Recode race and other demographics
# 06 - Clean up addresses
# 06a - Geocode addresses
# 07 - Consolidate data rows
# 08 - Add in final data elements and set up analyses
# 09 - Join with Medicaid eligibility data
# 10 - Set up joint housing/Medicaid analyses ### (THIS CODE) ###
#
# Alastair Matheson (PHSKC-APDE)
# alastair.matheson@kingcounty.gov
# 2016-08-13, split into separate files 2017-10
# 
###############################################################################


##### Set up global parameter and call in libraries #####
options(max.print = 350, tibble.print_max = 30, scipen = 999)
housing_path <- "//phdata01/DROF_DATA/DOH DATA/Housing"

library(odbc) # Used to connect to SQL server
library(openxlsx) # Used to import/export Excel files
library(lubridate) # Used to manipulate dates
library(tidyverse) # Used to manipulate data

##### Connect to the servers #####
db.apde51 <- dbConnect(odbc(), "PH_APDEStore51")
db.claims51 <- dbConnect(odbc(), "PHClaims51")


##### Bring in data #####
pha_mcaid_join <- readRDS(file = paste0(housing_path, 
                                        "/OrganizedData/pha_mcaid_join.Rda"))


#### SET UP VARIABLES FOR ANALYSES ####
### Set up person-time each year
# First set up intervals for each year
i2012 <- interval(start = "2012-01-01", end = "2012-12-31")
i2013 <- interval(start = "2013-01-01", end = "2013-12-31")
i2014 <- interval(start = "2014-01-01", end = "2014-12-31")
i2015 <- interval(start = "2015-01-01", end = "2015-12-31")
i2016 <- interval(start = "2016-01-01", end = "2016-12-31")
i2017 <- interval(start = "2017-01-01", end = "2017-12-31")

# Person-time in housing, needs to be done separately to avoid errors
pt_temp_h <- pha_mcaid_join %>%
  distinct(pid2, startdate_h, enddate_h) %>%
  filter(!is.na(startdate_h)) %>%
  mutate(
    pt12_h = (lubridate::intersect(interval(start = startdate_h, end = enddate_h), i2012) / ddays(1)) + 1,
    pt13_h = (lubridate::intersect(interval(start = startdate_h, end = enddate_h), i2013) / ddays(1)) + 1,
    pt14_h = (lubridate::intersect(interval(start = startdate_h, end = enddate_h), i2014) / ddays(1)) + 1,
    pt15_h = (lubridate::intersect(interval(start = startdate_h, end = enddate_h), i2015) / ddays(1)) + 1,
    pt16_h = (lubridate::intersect(interval(start = startdate_h, end = enddate_h), i2016) / ddays(1)) + 1,
    pt17_h = (lubridate::intersect(interval(start = startdate_h, end = enddate_h), i2017) / ddays(1)) + 1
  )

pha_mcaid_final <- left_join(pha_mcaid_join, pt_temp_h, by = c("pid2", "startdate_h", "enddate_h"))
rm(pt_temp_h)

# Person-time in Medicaid, needs to be done separately to avoid errors
pt_temp_m <- pha_mcaid_final %>%
  filter(!is.na(startdate_m)) %>%
  distinct(pid2, startdate_m, enddate_m) %>%
  mutate(
    pt12_m = (lubridate::intersect(interval(start = startdate_m, end = enddate_m), i2012) / ddays(1)) + 1,
    pt13_m = (lubridate::intersect(interval(start = startdate_m, end = enddate_m), i2013) / ddays(1)) + 1,
    pt14_m = (lubridate::intersect(interval(start = startdate_m, end = enddate_m), i2014) / ddays(1)) + 1,
    pt15_m = (lubridate::intersect(interval(start = startdate_m, end = enddate_m), i2015) / ddays(1)) + 1,
    pt16_m = (lubridate::intersect(interval(start = startdate_m, end = enddate_m), i2016) / ddays(1)) + 1,
    pt17_m = (lubridate::intersect(interval(start = startdate_m, end = enddate_m), i2017) / ddays(1)) + 1
  )

pha_mcaid_final <- left_join(pha_mcaid_final, pt_temp_m, by = c("pid2", "startdate_m", "enddate_m"))
rm(pt_temp_m)

# Person-time in both, needs to be done separately to avoid errors
pt_temp_o <- pha_mcaid_final %>%
  filter(!is.na(startdate_o)) %>%
  distinct(pid2, startdate_o, enddate_o) %>%
  mutate(
    pt12_o = (lubridate::intersect(interval(start = startdate_o, end = enddate_o), i2012) / ddays(1)) + 1,
    pt13_o = (lubridate::intersect(interval(start = startdate_o, end = enddate_o), i2013) / ddays(1)) + 1,
    pt14_o = (lubridate::intersect(interval(start = startdate_o, end = enddate_o), i2014) / ddays(1)) + 1,
    pt15_o = (lubridate::intersect(interval(start = startdate_o, end = enddate_o), i2015) / ddays(1)) + 1,
    pt16_o = (lubridate::intersect(interval(start = startdate_o, end = enddate_o), i2016) / ddays(1)) + 1,
    pt17_o = (lubridate::intersect(interval(start = startdate_o, end = enddate_o), i2017) / ddays(1)) + 1
  )

pha_mcaid_final <- left_join(pha_mcaid_final, pt_temp_o, by = c("pid2", "startdate_o", "enddate_o"))
rm(pt_temp_o)

# Person-time specific to that interval, doesn't need to be done separately
pha_mcaid_final <- pha_mcaid_final %>%
  mutate(
    pt12 = (lubridate::intersect(interval(start = startdate_c, end = enddate_c), i2012) / ddays(1)) + 1,
    pt13 = (lubridate::intersect(interval(start = startdate_c, end = enddate_c), i2013) / ddays(1)) + 1,
    pt14 = (lubridate::intersect(interval(start = startdate_c, end = enddate_c), i2014) / ddays(1)) + 1,
    pt15 = (lubridate::intersect(interval(start = startdate_c, end = enddate_c), i2015) / ddays(1)) + 1,
    pt16 = (lubridate::intersect(interval(start = startdate_c, end = enddate_c), i2016) / ddays(1)) + 1,
    pt17 = (lubridate::intersect(interval(start = startdate_c, end = enddate_c), i2017) / ddays(1)) + 1
  )


### Age
pha_mcaid_final <- pha_mcaid_final %>%
  mutate(age12 = floor(lubridate::interval(start = dob_c, end = ymd(20121231)) / years(1), 1),
         age13 = floor(lubridate::interval(start = dob_c, end = ymd(20131231)) / years(1), 1),
         age14 = floor(lubridate::interval(start = dob_c, end = ymd(20141231)) / years(1), 1),
         age15 = floor(lubridate::interval(start = dob_c, end = ymd(20151231)) / years(1), 1),
         age16 = floor(lubridate::interval(start = dob_c, end = ymd(20161231)) / years(1), 1),
         age17 = floor(lubridate::interval(start = dob_c, end = ymd(20171231)) / years(1), 1)
  ) %>%
  # Remove negative ages
  mutate_at(vars(age12:age17), funs(ifelse(. < 0, 0.01, .)))


### Gender
pha_mcaid_final <- pha_mcaid_final %>%
  mutate(gender_c = case_when(
    gender_c == 1 ~ "Female",
    gender_c == 2 ~ "Male",
    gender_c == 3 ~ "Multiple",
    TRUE ~ "Unknown"
  ))


### Race/ethnicity
pha_mcaid_final <- pha_mcaid_final %>%
  mutate(ethn_c = case_when(
    hisp_c == 1 & !is.na(hisp_c) ~ "Hispanic",
    str_detect(race_c, "AIAN|AI/AN") ~ "AI/AN",
    str_detect(race_c, "Asian") ~ "Asian",
    str_detect(race_c, "Black") ~ "Black",
    str_detect(race_c, "Multiple") ~ "Multiple",
    str_detect(race_c, "NHPI|NH/PI") ~ "NH/PI",
    str_detect(race_c, "White") ~ "White",
    str_detect(race_c, "Other") ~ "Other"
  ))
  

### Length of time in housing
pha_mcaid_final <- pha_mcaid_final %>%
  mutate(length12 = round(interval(start = start_housing, end = ymd(20121231)) / years(1), 1),
         length13 = round(interval(start = start_housing, end = ymd(20131231)) / years(1), 1),
         length14 = round(interval(start = start_housing, end = ymd(20141231)) / years(1), 1),
         length15 = round(interval(start = start_housing, end = ymd(20151231)) / years(1), 1),
         length16 = round(interval(start = start_housing, end = ymd(20161231)) / years(1), 1),
         length17 = round(interval(start = start_housing, end = ymd(20171231)) / years(1), 1)
  ) %>%
  # Remove negative lengths
  mutate_at(vars(length12:length17), funs(ifelse(. < 0, NA, .)))


### Agency
pha_mcaid_final <- pha_mcaid_final %>%
  mutate(agency_new = ifelse(is.na(agency_new), "Non-PHA", agency_new))

#### Save point ####
saveRDS(pha_mcaid_final, file = paste0(housing_path, 
                                      "/OrganizedData/pha_mcaid_final.Rda"))


#### Write to SQL for joining with claims ####
# Write full data set here and stripped down numeric data below
dbRemoveTable(db.apde51, name = "housing_mcaid")
system.time(dbWriteTable(db.apde51, name = "housing_mcaid", 
                         value = as.data.frame(pha_mcaid_final), overwrite = T,
                         field.types = c(
                           startdate_h = "date", enddate_h = "date", 
                           startdate_m = "date", enddate_m = "date", 
                           startdate_o = "date", enddate_o = "date", 
                           startdate_c = "date", enddate_c = "date",
                           dob_h = "date", dob_m = "date", dob_c = "date", 
                           hh_dob_h = "date",
                           move_in_date = 'date', start_housing = "date", 
                           start_pha = "date", start_prog = "date"))
)



#### Encode key demographics for analysis ####
# Make main demogs used in analysis numeric to speed read/write to SQL and joins
# Use lookup table to make numeric mappings - eventually, manual for now
pha_mcaid_demo <- pha_mcaid_final %>%
  mutate(
    agency_num = case_when(
      agency_new == "Non-PHA" ~ 0,
      agency_new == "KCHA" ~ 1,
      agency_new == "SHA" ~ 2,
      TRUE ~ 99
    ),
    dual_elig_num = case_when(
      dual_elig_m == "Y" ~ 1,
      dual_elig_m == "N" ~ 2,
      is.na(dual_elig_m) ~ 99
    ),
    enroll_type_num = case_when(
      enroll_type == "h" ~ 1,
      enroll_type == "m" ~ 2,
      enroll_type == "b" ~ 3
    ),
    ethn_num = case_when(
      hisp_c == 1 & !is.na(hisp_c) ~ 4,
      is.na(race_c) | race_c == "" ~ 99,
      str_detect(race_c, "AIAN|AI/AN") ~ 1,
      str_detect(race_c, "Asian") ~ 2,
      str_detect(race_c, "Black") ~ 3,
      str_detect(race_c, "Multiple") ~ 5,
      str_detect(race_c, "NHPI|NH/PI") ~ 6,
      str_detect(race_c, "White") ~ 7,
      str_detect(race_c, "Other") ~ 8
    ),
    gender_num = case_when(
      gender_c == "Female" ~ 1,
      gender_c == "Male" ~ 2,
      gender_c == "Multiple" ~ 3,
      TRUE ~ 99
    ),
    operator_num = case_when(
      operator_type == "NON-PHA OPERATED" ~ 1,
      operator_type == "PHA OPERATED" ~ 2,
      operator_type == "" ~ 99,
      is.na(operator_type) ~ 0
    ),
    portfolio_num = case_when(
      portfolio_final == "BIRCH CREEK" ~ 1,
      portfolio_final == "FAMILY" ~ 2,
      portfolio_final == "GREENBRIDGE" ~ 3,
      portfolio_final == "HIGH POINT" ~ 4,
      str_detect(portfolio_final, "HIGHRISE") ~ 5,
      portfolio_final == "LAKE CITY COURT" ~ 6,
      portfolio_final == "MIXED" ~ 7,
      portfolio_final == "NEWHOLLY" ~ 8,
      portfolio_final == "RAINIER VISTA" ~ 9,
      str_detect(portfolio_final, "SCATTERED SITES") ~ 10,
      portfolio_final == "SENIOR" ~ 11,
      portfolio_final == "SENIOR HOUSING" ~ 11,
      portfolio_final == "SEOLA GARDENS" ~ 12,
      portfolio_final == "VALLI KEE" ~ 13,
      portfolio_final == "YESLER TERRACE" ~ 14,
      str_detect(portfolio_final, "OTHER") ~ 15,
      portfolio_final == "" ~ 88,
      is.na(portfolio_final) ~ 0
    ),
    subsidy_num = case_when(
      subsidy_type == "HARD UNIT" ~ 1,
      subsidy_type == "TENANT BASED/SOFT UNIT" ~ 2,
      is.na(subsidy_type) ~ 0
    ),
    voucher_num = case_when(
      vouch_type_final == "AGENCY TENANT-BASED VOUCHER" ~ 1,
      vouch_type_final == "FUP" ~ 2,
      vouch_type_final == "GENERAL TENANT-BASED VOUCHER" ~ 3,
      vouch_type_final == "HASP" ~ 4,
      vouch_type_final == "MOD REHAB" ~ 5,
      vouch_type_final == "OTHER (TI/DV)" ~ 6,
      vouch_type_final == "PARTNER PROJECT-BASED VOUCHER" ~ 7,
      vouch_type_final == "PHA OPERATED VOUCHER" ~ 8,
      vouch_type_final == "VASH" ~ 9,
      vouch_type_final == "" ~ 88,
      is.na(vouch_type_final) ~ 0
    )
  )


# Function to recode ages
agecode_f <- function(df, x) {
  col <- enquo(x)
  varname <- paste(quo_name(col), "num", sep = "_")
  df %>%
    mutate(!!varname := case_when(
      (!!col) < 18 ~ 1,
      between((!!col), 18, 24.99) ~ 2,
      between((!!col), 25, 44.99) ~ 3,
      between((!!col), 45, 61.99) ~ 4,
      between((!!col), 62, 64.99) ~ 5,
      (!!col) >= 65 ~ 6,
      is.na((!!col)) ~ 99
    )
    )
}

# Function to recode lengths
lencode_f <- function(df, x, agency = agency_new) {
  col <- enquo(x)
  agency <- enquo(agency)
  
  varname <- paste(quo_name(col), "num", sep = "_")
  df %>%
    mutate(!!varname := case_when(
      (!!col) < 3 ~ 1,
      between((!!col), 3, 5.99) ~ 2,
      (!!col) >= 6 ~ 3,
      is.na((!!agency)) | (!!agency) == "Non-PHA" | (!!agency) == 0 ~ 0,
      is.na((!!col)) ~ 99
    )
    )
}

pha_mcaid_demo <- agecode_f(pha_mcaid_demo, age12)
pha_mcaid_demo <- agecode_f(pha_mcaid_demo, age13)
pha_mcaid_demo <- agecode_f(pha_mcaid_demo, age14)
pha_mcaid_demo <- agecode_f(pha_mcaid_demo, age15)
pha_mcaid_demo <- agecode_f(pha_mcaid_demo, age16)
pha_mcaid_demo <- agecode_f(pha_mcaid_demo, age17)
  
pha_mcaid_demo <- lencode_f(pha_mcaid_demo, length12)
pha_mcaid_demo <- lencode_f(pha_mcaid_demo, length13)
pha_mcaid_demo <- lencode_f(pha_mcaid_demo, length14)
pha_mcaid_demo <- lencode_f(pha_mcaid_demo, length15)
pha_mcaid_demo <- lencode_f(pha_mcaid_demo, length16)
pha_mcaid_demo <- lencode_f(pha_mcaid_demo, length17)


#### Restrict to just the columns needed ####
# Just ID, date, DOB, numeric demogs, ZIP, and person-time here
pha_mcaid_demo <- pha_mcaid_demo %>%
  select(mid, pid2, startdate_c, enddate_c, 
         dob_c, start_housing, zip_c, age12_num:age17_num,
         agency_num, dual_elig_num, enroll_type_num, gender_num, ethn_num,
         length12_num:length17_num, operator_num, portfolio_num, 
         subsidy_num, voucher_num, unit_zip_h, pt12:pt17)



#### Save point ####
saveRDS(pha_mcaid_demo, file = paste0(housing_path, 
                                      "/OrganizedData/pha_mcaid_demo.Rda"))


#### Write to SQL for joining with claims ####
dbRemoveTable(db.apde51, name = "housing_mcaid_demo")
system.time(dbWriteTable(db.apde51, name = "housing_mcaid_demo", 
             value = as.data.frame(pha_mcaid_demo), overwrite = T,
             field.types = c(
               startdate_c = "date",
               enddate_c = "date",
               dob_c = "date",
               time_housing = "date"))
)


#### Final clean up ####
rm(list = ls(pattern = "i20"))
rm(pha_mcaid_join)
gc()

