# what samples do not have a ligation ID?

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)
leyte <- src_mysql(dbname = "Leyte", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

# get a list of all sample ID's from the field database that begin with APCL and have characters after 

fish <- leyte %>% tbl("clownfish") %>% select(sample_id) %>% filter(sample_id %like% "APCL%")
fish_local <- collect(fish)

# find the extraction IDs for those Samples
extr <- labor %>% tbl("extraction") %>% select (sample_id, extraction_id)
extr <- left_join(fish, extr, by = "sample_id", copy = T)

# find digest IDs for  samples
dig <- labor %>% tbl("digest") %>% select(digest_id, extraction_id) 
dig <- left_join(extr, dig, by = "extraction_id", copy = T)

# find ligation IDs for samples
lig <- labor %>% tbl("ligation") %>% select(digest_id, ligation_id) 
lig <- left_join(dig, lig, by = "digest_id", copy = T)

# bring data over to local environment
ligated <- collect(lig)

# TESTING - make sure rows add up - this is just first step in test
k <- nrow(ligated)
#

# Separate table into extracted and not extracted samples
not_ligated <- ligated[is.na(ligated$ligation_id), ]
ligated <- ligated[!is.na(ligated$ligation_id), ]

#TESTING - should be TRUE
nrow(not_ligated) + nrow(ligated) == k

# check to see if any sample IDs from the ligated list match sample IDs from the not ligated list
test <- left_join(ligated, not_ligated, by = "sample_id")

### THERE ARE SAMPLES IN BOTH LISTS, MUST DETERMINE IF REALLY WANT TO REGENOTYPE ###
