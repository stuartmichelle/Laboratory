# Add Source locations, starting with the first plate ---------------------


# search the database for all of the extracts done on the same day as the first extract we are looking for
E1 <- data.frame(labor %>% tbl("extraction") %>% select(extraction_ID, date) %>% filter(date == dest$date[1]), stringsAsFactors = F)

# find the ID of the first extract of the plate that holds the extract we want
S1_first <- E1$extraction_ID[floor(which(E1$extraction_ID == dest$extraction_ID[1])/96)*96 + 1]

# file the file list of extracts and locations on our plate 
filelist <- sort(list.files(path="data/", pattern = S1_first), decreasing=FALSE)

# pick that file from the list
pick <- paste("data/", filelist[1], sep = "")

# read in the csv of plate locations
S1 <- read.csv(pick[1], row.names = 1)

# rename the columns
names(S1) <- c("Row", "Col", "ID")

# match the source well locations to our destination plate extracts
dest <- merge(dest, S1, by.x = "extraction_ID", by.y = "ID", all.x = T)

# combine row and col columns to one plate location
dest$sourcewell <- paste(dest$Row, dest$Col, sep = "")

# clean up
dest$Row <- NULL
dest$Col <- NULL

# move the located extracts to their own table and define a source location
S1 <- dest[which(dest$sourcewell != "NANA"), ]

# reset the dest table with only extracts that still need to be located and repeat
dest <- dest[which(dest$sourcewell == "NANA"), ]
