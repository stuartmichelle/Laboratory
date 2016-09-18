# assign digest numbers to the extracts we set up in the plate - this is a special case 

# determine which, if any, samples from the extract plate cannot be digested (DNA > 5ug)

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

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

# cut down to one plate size
need <- need[1:96, ]

# add digest numbers
n <- data.frame(labor %>% tbl("digest") %>% summarize(n()))
x <- n[1,]
need$digest_ID <- 1:96
need$digest_ID <- paste("D", (need$digest_ID + x), sep = "")


# create a platemap
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, need[,4])
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# create a source map
sourcelist <- cbind(plate, need[1])
names(sourcelist) <- c("Row", "Col", "ID")
sourcelist$ID <- as.character(sourcelist$ID)
sourcemap <- as.matrix(reshape2::acast(sourcelist,sourcelist[,1] ~ sourcelist[,2]))
write.csv(sourcemap, file = paste("data/", Sys.Date(), "map.csv", sep = ""))

##################################################################################
# After digest is complete, add additional info (enzymes, final vol, quant, DNA)

# create an import file for database
write.csv(need, file = paste("data/", Sys.Date(), "digestforimport.csv", sep = ""))
