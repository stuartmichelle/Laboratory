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
# write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
# write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))


# After digest is complete, add additional info (enzymes, final vol, quant, DNA)

need$date <- as.Date("2016-09-18")
need$enzymes <- "PstI_MluCI"
need$final_vol <- 40

# reorder columns
need <- need[ , c(7, 4, 8, 5, 6, 9, 10, 2, 3)]

# add quantification data

### EDIT the plate reader document so that it can be imported - delete header/footer, open in excel, check columns and save as csv - have to open in excel and save as because it contains embedded nulls
# import plate reader results for quantificaiton
pr <- read.csv("data/20160919_plate1.csv", stringsAsFactors = F, header = T)

# convert plate list to plate locations
platelist$Wells <- paste(platelist$Row, platelist$Col, sep = "")

# remove first row
platelist2 <- platelist[7:96, ]

# join platelist id's to plate reader locations 
### THIS WILL NOT WORK FOR FIRST COLUMN OF PLATE ###
pr <- left_join(pr, platelist, by = "Wells")

# add quants to need table
need1 <- merge(need[7:93, ], pr[ , c("AdjResult", "ID")], by.x = "digest_ID", by.y = "ID", all.x = T)

# add quants for column 1
### EDIT the plate reader document so that it can be imported - delete header/footer, open in excel, check columns and save as csv - have to open in excel and save as because it contains embedded nulls
# import plate reader results for quantificaiton
pr <- read.csv("data/20160919_plate2.csv", stringsAsFactors = F, header = T)

# remove all rows but the first
platelist2 <- platelist[1:6, ]

# adjust for the location of the column on the plate
platelist2$Col <- 2

# convert plate list to plate locations
platelist2$Wells <- paste(platelist2$Row, platelist2$Col, sep = "")

# join platelist id's to plate reader locations 
pr <- left_join(pr, platelist2, by = "Wells")

# add quants to need table
need2 <- merge(need[1:6, ], pr[ , c("AdjResult", "ID")], by.x = "digest_ID", by.y = "ID", all.x = T)

need <- rbind(need1, need2)

# calculate amount of DNA in digest
need$DNA_ng <- need$final_vol * need$AdjResult

need$Row <- NULL
need$Col <- NULL


# create an import file for database
write.csv(need, file = paste("data/", Sys.Date(), "digestforimport.csv", sep = ""))


# evaluate results of digest
prob <- need %>% filter(DNA_ng < 100)
