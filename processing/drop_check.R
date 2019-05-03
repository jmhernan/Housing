library(data.table)
pha_rebase <- readRDS("~/data/Housing/OrganizedData/pha_longitudinal_uw.Rds")

pha_original <- fread(file ='~/data/HILD/pha_longitudinal.csv')

pha_updated <- fread(file ='~/data/HILD/pha_longitudinal_04_19.csv')


drop_track <- readRDS("~/data/Housing/OrganizedData/drop_track_uw.Rda")


pha_og_names <- pha_original %>% 
  select(ssn_new, lname_new, fname_new, agency_new) %>% unique() %>% na.omit

sum(is.na(pha_rebase$lname_new))

pha_up_names <- pha_rebase %>%
  select(ssn_new, lname_new, fname_new, agency_new) %>% unique()

# names not found in rebase

no_match <- anti_join(pha_og_names, pha_up_names, by = c("ssn_new","lname_new", "fname_new", "agency_new")) %>%
  unique()

# check drop track 
library(stringr)
dropped <- drop_track %>%
  #select(lname_new, fname_new, agency_prog_concat) %>%
  mutate(agency_new = substr(agency_prog_concat,1, regexpr(",", agency_prog_concat)-1)) %>%
  filter(drop != 0)


drop_cases <- left_join(no_match,dropped, by = c("lname_new", "fname_new", "agency_new"))

drop_cases %>% 
  select(drop) %>%
  table()

test <- drop_cases %>% 
  select(-drop, -row, -act_type) %>% unique() 
