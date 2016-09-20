# what samples do not have a ligation ID?

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)
leyte <- src_mysql(dbname = "Leyte", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

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

# get more information about samples

# get digest info 
dig <- labor %>% tbl("digest") %>% select(digest_id, extraction_id, date, quant, notes, enzymes) 
not_ligated <- left_join(not_ligated, dig, by = "digest_id", copy = T)
not_ligated$extraction_id.y <- NULL

# remove digests that were not quantified because they are test digests from early days
not_ligated <- not_ligated[!is.na(not_ligated$quant), ]

# remove digests that are too low in concentration to ligate (< 0.45ng/µL)
not_ligated <- not_ligated[which(not_ligated$quant > 0.45), ]

# remove digests that have been marked as empty
empty <- filter(not_ligated, grepl('empty', notes))
for (i in 1:nrow(empty)){
  j <- which(empty$sample_id[i] == not_ligated$sample_id)
  not_ligated$sample_id[j] <- NA
}
not_ligated <- not_ligated[!is.na(not_ligated$sample_id), ]

# remove digests that were made using the wrong enzymes
not_ligated <- not_ligated[which(not_ligated$enzymes == "PstI_MluCI"), ]

# remove bioanalyzer samples by date
not_ligated <- not_ligated[which(not_ligated$date != "2014-11-11"), ]

# remove bioanalyzer samples by date
not_ligated <- not_ligated[which(not_ligated$date != "2014-12-11"), ]

# remove the one sample that still shows up on both lists that doesn't need to be regenotyped
not_ligated <- not_ligated[which(not_ligated$digest_id != "D1232"), ]


# check to see if any sample IDs from the ligated list match sample IDs from the not ligated list
test <- left_join(ligated, not_ligated, by = "sample_id")

### NOW ALL THAT IS LEFT ON THE TEST LIST ARE THE SAMPLES WE PLAN TO REGENOTYPE, PERFECT ###
