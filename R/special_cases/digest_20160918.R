# assign digest numbers to the extracts we set up in the plate - this is a special case 
# Have to finish my fill it plate and add to database before I can plan more digests 
# to add to the ligation.

# import list of extracts from biomek plan
need <- read.csv("data/biomek20160915_extracttodigestlist.csv", stringsAsFactors = F)

# add the volume column
need$vol_in <- 30

# get quantification data from database
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)
extr <- data.frame(labor %>% tbl("extraction") %>% select (extraction_ID, quant))
# remove any extractions not in our list
extr <- left_join(need, extr, by = "extraction_ID")

need$ng_in <- (extr$quant)*30

# make sure everything is in order
need <- need[order(need$Col,need$Row), ]

# add digest numbers
n <- data.frame(labor %>% tbl("digest") %>% summarize(n()))
x <- n[1,]
need$digest_ID <- 1:93
need$digest_ID <- paste("D", (need$digest_ID + x), sep = "")


# create a platemap of digest numbers

platelist <- need[ , c(2,3,7)]
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

##################################################################################
# After digest is complete, add additional info (enzymes, final vol, quant, DNA)

# create an import file for database
write.csv(need, file = paste("data/", Sys.Date(), "digestforimport.csv", sep = ""))
