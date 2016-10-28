# plan a digest run

# determine which, if any, samples from the extract plate cannot be digested (DNA > 5ug)

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# access all digest and extract IDs
suppressWarnings(digextr <- labor %>% tbl("digest") %>% select(extraction_id, digest_id) %>% collect())

# attach extract date and quantification
suppressWarnings(extr <- labor %>% tbl("extraction") %>% select (extraction_id, date, quant) %>% collect())

# merge so that all extraction IDs that have not been digested have an NA for digest ID
dig_extr <- full_join(extr, digextr, by = "extraction_id")

# create a table for all extracts that do not have a digest ID
# eliminate samples with less than 1ug of DNA ( less than 25ng/uL)
todig <- subset(dig_extr, is.na(digest_id) & quant > 25)

# want to use only extracts from a certain date
todig <- subset(todig, date == as.Date("2016-09-06"))

# calculate the amount of DNA that will be added
todig$vol_in <- 30
todig$ng_in <- (todig$quant)*(todig$vol_in)

# cut down to one plate size
todig <- todig[1:96, ]

# add digest numbers
suppressWarnings(n <- labor %>% tbl("digest") %>% summarize(n()) %>% collect())
x <- n[1,]
todig$digest_ID <- 1:96
todig$digest_ID <- paste("D", (todig$digest_ID + x), sep = "")


# create a platemap
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, todig[,4])
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
# write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
# write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# create a source map
sourcelist <- cbind(plate, todig[1])
names(sourcelist) <- c("Row", "Col", "ID")
sourcelist$ID <- as.character(sourcelist$ID)
sourcemap <- as.matrix(reshape2::acast(sourcelist,sourcelist[,1] ~ sourcelist[,2]))
# write.csv(sourcemap, file = paste("data/", Sys.Date(), "map.csv", sep = ""))

##################################################################################
# After digest is complete, add additional info (enzymes, final vol, quant, DNA)

# create an import file for database
# write.csv(todig, file = paste("data/", Sys.Date(), "digestforimport.csv", sep = ""))
