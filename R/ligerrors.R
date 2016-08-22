# This is a script to find Ligations that need to be re-done due to lab error

# Connect to databases
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)
leyte <- src_mysql(dbname = "Leyte", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# get the list of ligations that need to be regenotyped
ligs <- data.frame(leyte %>% tbl("known_issues"))
ligs <- filter(ligs, grepl('regenotype', Issue))



# # make sure they aren't on the list of good matches
# matches <- read.csv("~/Documents/Philippines/Genetics/2016-08-19matches.csv")
# 
# bingo <- data.frame(Ligation_ID = character(0), Issue = character(0))
# 
# for (i in 1:nrow(ligs)){
# bingo$Ligation_ID[i] <- ligs$Ligation_ID[which(ligs$Ligation_ID[i] == matches$First.ID)]
# }
# 
# for (i in 1:nrow(ligs)){
#   bingo$Ligation_ID[i] <- ligs$Ligation_ID[which(ligs$Ligation_ID[i] == matches$Second.ID)]
# }

# Find the extraction IDs of the samples to be regenotyped
c1 <- labor %>% tbl("extraction") %>% select(extraction_ID, sample_ID, date)
c2 <- labor %>% tbl("digest") %>% select(digest_ID, extraction_ID)
c3 <- left_join(c2, c1, by = "extraction_ID")
c4 <- labor %>% tbl("ligation") %>% select(ligation_ID, digest_ID)
c5 <- left_join(c4, c3, by = "digest_ID")
ligs <- left_join(ligs, c5, by = c("Ligation_ID" = "ligation_ID"), copy = T )

# remove repeat extraction_IDs
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
  
# add source positions to each of the source plates
extract$sourceloc[extract$sourceloc == 1 | extract$sourceloc == 11 ] <- "P13"
extract$sourceloc[extract$sourceloc == 2 | extract$sourceloc == 12 ] <- "P2"
extract$sourceloc[extract$sourceloc == 3 | extract$sourceloc == 13 ] <- "P2"
extract$sourceloc[extract$sourceloc == 4 | extract$sourceloc == 14 ] <- "P4"
extract$sourceloc[extract$sourceloc == 5 | extract$sourceloc == 15 ] <- "P5"
extract$sourceloc[extract$sourceloc == 6 | extract$sourceloc == 16 ] <- "P6"
extract$sourceloc[extract$sourceloc == 7 | extract$sourceloc == 17 ] <- "P7"
extract$sourceloc[extract$sourceloc == 8 | extract$sourceloc == 18 ] <- "P8"
extract$sourceloc[extract$sourceloc == 9 | extract$sourceloc == 19 ] <- "P9"
extract$sourceloc[extract$sourceloc == 10] <- "P10"

# add pipet volume for digest
extract$sourcevol <- 30

write.csv(extract, file = paste(Sys.Date(), "biomek.csv", sep = ""))
