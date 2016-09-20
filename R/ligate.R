# plan a ligation run

# find samples that need to be ligated

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# pull digest IDs from ligation table
ligdig <- data.frame(labor %>% tbl("ligation") %>% select(ligation_ID, digest_ID))

# pull digest IDs from digest table
dig <- data.frame(labor %>% tbl("digest") %>% select (digest_ID, date, quant, Notes))

# merge so that all extraction IDs that have not been digested have an NA for digest ID
done <- full_join(dig, ligdig, by = "digest_ID")

# create a table for all extracts that do not have a digest ID
need <- done[is.na(done$ligation_ID),]

# eliminate samples with less than 10ng of DNA in 22.2µL (0.45ng/µL)
need <- need[which(need$quant > 0.45), ]

# sort by date and use most recent ligations
need <- need[order(need$date, decreasing = T), ] 

need$DNA <- NA

# calculate the volume of sample to add 200ng
need$vol_in <- 200/need$quant

twohundy <- need[which(need$vol_in <= 22.2), ]
twohundy <- twohundy[order(twohundy$vol_in), ]

# limit pool size
if (nrow(twohundy) > 48){
  twohundy <- twohundy[1:48, ]
}

twohundy$DNA <- 200

# remove the two hundies from the need list
for (i in 1:nrow(twohundy)){
  j <- which(twohundy$digest_ID[i] == need$digest_ID)
  need$digest_ID[j] <- NA
}
need <- need[!is.na(need$digest_ID), ]


# calculate the volume of sample to add 150ng
need$vol_in <- 150/need$quant



twohundy <- need[which(need$vol_in <= 22.2), ]
twohundy <- twohundy[order(twohundy$vol_in), ]
twohundy <- twohundy[1:48, ]
twohundy$DNA <- 200

# rejoin twohundy to the need list
need <- rbind(need, twohundy)

##############################################################################



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
