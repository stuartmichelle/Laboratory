# plan a ligation run

### IN THIS SCRIPT, ALL OF THE WRITE.CSV LINES HAVE BEEN COMMENTED OUT BECAUSE THESE SAMPLES HAVE ALREADY BEEN WRITTEN TO FILE, UNCOMMENT FOR NEW SAMPLES ###

# find samples that tolig to be ligated

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

# pull digest ids from ligation table
suppressWarnings(ligdig <- labor %>% tbl("ligation") %>% select(ligation_id, digest_id) %>% collect())

# pull digest ids from digest table
suppressWarnings(dig <- labor %>% tbl("digest") %>% select (digest_id, date, quant, notes) %>% collect())

# merge so that all extraction ids that have not been digested have an NA for digest id
lig_dig <- full_join(dig, ligdig, by = "digest_id")

# create a table for all extracts that do not have a digest id
tolig <- subset(lig_dig, is.na(ligation_id))

# eliminate samples with less than 10ng of DNA in 22.2µL (0.45ng/µL)
tolig <- subset(tolig, quant > 0.45)

# sort by date and use most recent ligations
tolig <- tolig[order(tolig$date, decreasing = T), ] 

tolig$DNA <- NA

# calculate the volume of sample to add 200ng
tolig$vol_in <- 200/tolig$quant

twohundy <- subset(tolig, vol_in <= 22.2)
twohundy <- twohundy[order(twohundy$vol_in), ]

# limit pool size
if (nrow(twohundy) > 48){
  twohundy <- twohundy[1:48, ]
}

twohundy$DNA <- 200

# remove the two hundies from the tolig list
for (i in 1:nrow(twohundy)){
  j <- which(twohundy$digest_id[i] == tolig$digest_id)
  tolig$digest_id[j] <- NA
}
tolig <- tolig[!is.na(tolig$digest_id), ]


# calculate the volume of sample to add 150ng
tolig$vol_in <- 150/tolig$quant



twohundy <- tolig[which(tolig$vol_in <= 22.2), ]
twohundy <- twohundy[order(twohundy$vol_in), ]
twohundy <- twohundy[1:48, ]
twohundy$DNA <- 200

# rejoin twohundy to the tolig list
tolig <- rbind(tolig, twohundy)

##############################################################################



tolig$ng_in <- (tolig$quant)*30

# cut down to one plate size
tolig <- tolig[1:96, ]

# add digest numbers
n <- data.frame(labor %>% tbl("digest") %>% summarize(n()))
x <- n[1,]
tolig$digest_id <- 1:96
tolig$digest_id <- paste("D", (tolig$digest_id + x), sep = "")


# create a platemap
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, tolig[,4])
names(platelist) <- c("Row", "Col", "id")
first <- platelist$id[1]
last <- platelist$id[nrow(platelist)]
# write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$id <- as.character(platelist$id)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
# write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# create a source map
sourcelist <- cbind(plate, tolig[1])
names(sourcelist) <- c("Row", "Col", "id")
sourcelist$id <- as.character(sourcelist$id)
sourcemap <- as.matrix(reshape2::acast(sourcelist,sourcelist[,1] ~ sourcelist[,2]))
# write.csv(sourcemap, file = paste("data/", Sys.Date(), "map.csv", sep = ""))

##################################################################################
# After digest is complete, add additional info (enzymes, final vol, quant, DNA)

# create an import file for database
# write.csv(tolig, file = paste("data/", Sys.Date(), "digestforimport.csv", sep = ""))

