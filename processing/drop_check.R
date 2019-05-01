

pha_rebase <- fread(file ='~/data/HILD/pha_longitudinal_09_18.csv')

pha_original <- fread(file ='~/data/HILD/pha_longitudinal.csv')

pha_updated <- fread(file ='~/data/HILD/pha_longitudinal_04_19.csv')

pha_updated_now <- fread(file ='/home/ubuntu/data/HILD/pha_longitudinal_subprocess_4_19.csv')

drop_track <- readRDS("~/data/Housing/OrganizedData/drop_track.Rda")

pha_og_names <- pha_original %>% 
  select(lname_new, fname_new, agency_new) %>% unique() %>% na.omit

sum(is.na(pha_rebase$lname_new))
pha_up_names <- pha_rebase %>%
  select(lname_new, fname_new, agency_new) %>% unique()

# names not found in rebase

no_match <- anti_join(pha_og_names, pha_up_names, by = c("lname_new", "fname_new", "agency_new")) %>%
  unique()

# check drop track 
library(stringr)
dropped <- drop_track %>%
  #select(lname_new, fname_new, agency_prog_concat) %>%
  mutate(agency_new = substr(agency_prog_concat,1, regexpr(",", agency_prog_concat)-1)) #%>%
  #select(-agency_prog_concat) %>% unique()

drop_cases <- left_join(no_match,dropped, by = c("lname_new", "fname_new", "agency_new"))

drop_cases %>% 
  select(sha_source) %>%
  table()

drop_track_2 %>%
  select(drop) %>%
  table()
#### Drops by category on original data 
names(pha_original)
pha_original %>% glimpse()
###################
# create testable df for drop cases

