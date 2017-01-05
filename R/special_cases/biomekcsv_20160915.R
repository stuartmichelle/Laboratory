# This is a script to find Ligations that need to be re-done due to lab error
# When the robot was actually used on 9/15/2016, it was discovered that the span 8 pipet 
# would not move into the P2, P3, P4 positions, nor would it move into the P13 position on 
# round 3, so for round 3, the P13 was changed to P8 on the fly, and for round 1 and round 2, the
# P2, P3, P4 positions were deleted and a 4th round was created that contained the rows from round
# 1 and 2, with the positions changed to P5, 6, 7, 8, 9, and 10. 

# Connect to databases
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)
leyte <- src_mysql(dbname = "Leyte", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

# get the list of ligations that need to be regenotyped
ligs <- data.frame(leyte %>% tbl("known_issues"))
ligs <- filter(ligs, grepl('regenotype', Issue))

# Find the extraction IDs of the samples to be regenotyped
c1 <- labor %>% tbl("extraction") %>% select(extraction_ID, sample_ID, date)
c2 <- labor %>% tbl("digest") %>% select(digest_ID, extraction_ID)
c3 <- left_join(c2, c1, by = "extraction_ID")
c4 <- labor %>% tbl("ligation") %>% select(ligation_ID, digest_ID)
c5 <- left_join(c4, c3, by = "digest_ID")
ligs <- left_join(ligs, c5, by = c("Ligation_ID" = "ligation_ID"), copy = T )

# remove repeat extraction_IDs - should be 61 obs
ligs <- ligs %>% distinct(extraction_ID)

# cleanup 
rm(c1,c2,c3,c4,c5)

# make a platemap_list of the destination digests 
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))

# cut down to the number of rows needed
i <- nrow(ligs)
if(i < 96){
  plate <- plate[1:i,]
}

dest <- cbind(plate, ligs[ , c("Ligation_ID","extraction_ID", "date")])
dest$destwell <- paste(dest$Row, dest$Col, sep = "")

write.csv(dest, file = paste("data/", Sys.Date(), "dest_list.csv", sep = ""))
dest$extraction_ID <- as.character(dest$extraction_ID)
platemap <- as.matrix(reshape2::acast(dest,dest[,1] ~ dest[,2], value.var = "extraction_ID"))
write.csv(platemap, file = paste("data/", Sys.Date(), "dest_map.csv", sep = ""))


# clean up 
rm(i)
dest$Row <- NULL
dest$Col <- NULL
dest$Ligation_ID <- NULL
dest$sourcewell <- NA
dest$destloc <- "P12"
dest <- dest[order(dest$extraction_ID), ]

# make an extract empty data frame to bind new rows to
extract <- data.frame(extraction_ID = character(0), date = character(0), destwell = character(0), sourcewell = character(0), destloc = character(0))

# based on the date of the first extract in dest, find the extraction plate locations
source("R/eplatebydate.R")
for (i in 1:19){
  E1 <- data.frame(labor %>% tbl("extraction") %>% select(extraction_ID, date) %>% filter(date == dest$date[1]), stringsAsFactors = F)
  eplatebydate(E1)
  S1$sourceloc <- i
  extract <- rbind(extract, S1)
}

# 38 warnings ok...all imported decimal as numeric

extract$run <- NA
extract$run[extract$sourceloc == 1] <- 1
extract$run[extract$sourceloc == 2] <- 1
extract$run[extract$sourceloc == 3] <- 1
extract$run[extract$sourceloc == 4] <- 1
extract$run[extract$sourceloc == 5] <- 1
extract$run[extract$sourceloc == 6] <- 1
extract$run[extract$sourceloc == 7] <- 1
extract$run[extract$sourceloc == 8] <- 1
extract$run[extract$sourceloc == 9] <- 1
extract$run[extract$sourceloc == 10] <- 1
extract$run[extract$sourceloc == 11] <- 2
extract$run[extract$sourceloc == 12] <- 2
extract$run[extract$sourceloc == 13] <- 2
extract$run[extract$sourceloc == 14] <- 2
extract$run[extract$sourceloc == 15] <- 2
extract$run[extract$sourceloc == 16] <- 2
extract$run[extract$sourceloc == 17] <- 2
extract$run[extract$sourceloc == 18] <- 2
extract$run[extract$sourceloc == 19] <- 2


# add source positions to each of the source plates
extract$sourceloc[extract$sourceloc == 1 | extract$sourceloc == 11 ] <- "P13"
extract$sourceloc[extract$sourceloc == 2 | extract$sourceloc == 12 ] <- "P2"
extract$sourceloc[extract$sourceloc == 3 | extract$sourceloc == 13 ] <- "P3"
extract$sourceloc[extract$sourceloc == 4 | extract$sourceloc == 14 ] <- "P4"
extract$sourceloc[extract$sourceloc == 5 | extract$sourceloc == 15 ] <- "P5"
extract$sourceloc[extract$sourceloc == 6 | extract$sourceloc == 16 ] <- "P6"
extract$sourceloc[extract$sourceloc == 7 | extract$sourceloc == 17 ] <- "P7"
extract$sourceloc[extract$sourceloc == 8 | extract$sourceloc == 18 ] <- "P8"
extract$sourceloc[extract$sourceloc == 9 | extract$sourceloc == 19 ] <- "P9"
extract$sourceloc[extract$sourceloc == 10] <- "P10"

# add pipet volume for digest
extract$sourcevol <- 30

# split the samples by run
extract1 <- extract[extract$run == 1, ]
extract2 <- extract[extract$run == 2, ]

write.csv(extract1, file = paste(Sys.Date(), "biomek_1.csv", sep = ""))
write.csv(extract2, file = paste(Sys.Date(), "biomek_2.csv", sep = ""))

# fill in the rest of the plate with 2016 samples
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))

# cut off the top portion of the plate that is already filled
plate <- plate[62:96,]

### need 35 more samples ###

# pull extract IDs from digest table
digextr <- data.frame(labor %>% tbl("digest") %>% select(extraction_ID, digest_ID))

# pull extract IDs from extraction table
extr <- data.frame(labor %>% tbl("extraction") %>% select (extraction_ID, date, quant))

# merge so that all extraction IDs that have not been digested have an NA for digest ID
done <- full_join(extr, digextr, by = "extraction_ID")

# create a table for all extracts that do not have a digest ID
need <- done[is.na(done$digest_ID),]

# eliminate samples with less than 1ug of DNA ( less than 25ng/uL)
need <- need[which(need$quant > 25), ]

# want to use only extracts from a certain date
need <- need[which(need$date == as.Date("2016-09-06")), ]

# calculate the amount of DNA that will be added
need$vol_in <- 30

need$ng_in <- (need$quant)*30

# cut down to number of empty well in current plate
need <- need[1:nrow(plate), ]

# attach destination plate locations
dest3 <- cbind(plate, need[ , c("extraction_ID", "date")])
dest3$destwell <- paste(dest3$Row, dest3$Col, sep = "")

#cleanup
dest3$Row <- NULL
dest3$Col <- NULL

# based on the date of the first extract in dest, find the extraction plate locations
S1 <- read.csv("data/E2968-E3063list.csv", row.names = 1)

# merge the locations with the destination
dest3 <- merge(dest3, S1, by.x = "extraction_ID", by.y = "ID", all.x = T)

dest3$sourcewell <- paste(dest3$Row, dest3$Col, sep = "")
dest3$Row <- NULL
dest3$Col <- NULL
dest3$sourceloc <- "P13"
dest3$destloc <- "P12"
dest3$sourcevol <- 30

write.csv(dest3, file = paste(Sys.Date(), "biomek_3.csv", sep = ""))

# make a final list and map of digests
round1 <- read.csv("2016-09-15biomek_1.csv")
round2 <- read.csv("2016-09-15biomek_2.csv")
round3 <- read.csv("2016-09-15biomek_3.csv")

round3$run <- 3

# join the lists into one table
round <- rbind(round1, round2, round3)

# separate out the row and column from the destination plate
round$Row <- substr(round$destwell,1,1)
round$Col <- as.integer(substr(round$destwell,2,3)) 

roundlist <- round[order(round$Col), c(2, 10:11)]
roundlist <- roundlist [ , c(2, 3, 1)]
write.csv(roundlist, file = "data/biomek20160915_extracttodigestlist.csv")
roundlist$extraction_ID <- as.character(roundlist$extraction_ID)
platemap <- as.matrix(reshape2::acast(roundlist,roundlist[,1] ~ roundlist[,2], value.var = "extraction_ID"))
write.csv(platemap, file = "data/biomek20160915_extracttodigestmap.csv")

### NEXT STEP ###
# use the digest script to import the list and make digest numbers
