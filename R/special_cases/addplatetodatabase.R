# for plate maps that currently only exist on google sheets
# make a list of columns and rows (the locations for the platemap only)
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))

# import lab ids for the plate
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)


# get samples for date of interest 
# digest <- labor %>% tbl("digest") %>% filter(date == "2016-09-18") %>% collect()

# # if plate is smaller than 96 wells:
# # cut down to the number of rows needed
# i <- nrow(digest)
# if(i < 96){
#   plate <- plate[1:i,]
# }
# plate1 <- cbind(plate, digest[ , 1])
# # end small plate section

### GET SAMPLES FROM BIOMEK LIST ###
digest <- read.csv("data/2016-09-15biomek.csv", as.is = T)
digest$Row <- substr(digest$destwell, 1, 1)
digest$Col <- substr(digest$destwell, 2, 3)

# sort by plate location
digest <- arrange(digest, Col, Row)

digest$ID <- paste("D", )

 
# plate1 <- cbind(plate, digest[1:96,1])
# 
# names(plate1) <- c("Row", "Col", "ID")
# first <- plate1$ID[1]
# last <- plate1$ID[nrow(plate1)]
# # write.csv(plate1, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate1$ID <- as.character(plate1$ID)
platemap1 <- as.matrix(reshape2::acast(plate1,plate1[,1] ~ plate1[,2]))
# write.csv(platemap1, file = paste("data/", first, "-",last, "map.csv", sep = ""))

plate2 <- cbind(plate, digest[97:192,1])
names(plate2) <- c("Row", "Col", "ID")
first <- plate2$ID[1]
last <- plate2$ID[nrow(plate2)]
# write.csv(plate2, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate2$ID <- as.character(plate2$ID)
platemap2 <- as.matrix(reshape2::acast(plate2,plate2[,1] ~ plate2[,2]))
# write.csv(platemap2, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# 
# plate3 <- cbind(plate, digest[193:288,1])
# names(plate3) <- c("Row", "Col", "ID")
# first <- plate3$ID[1]
# last <- plate3$ID[nrow(plate3)]
# # write.csv(plate3, file = paste("data/", first, "-", last, "list.csv", sep = ""))
# plate3$ID <- as.character(plate3$ID)
# platemap3 <- as.matrix(reshape2::acast(plate3,plate3[,1] ~ plate3[,2]))
# # write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))
# 
# plate4 <- cbind(plate, digest[289:384,1])
# names(plate4) <- c("Row", "Col", "ID")
# first <- plate4$ID[1]
# last <- plate4$ID[nrow(plate4)]
# # write.csv(plate4, file = paste("data/", first, "-", last, "list.csv", sep = ""))
# plate4$ID <- as.character(plate4$ID)
# platemap <- as.matrix(reshape2::acast(plate4,plate4[,1] ~ plate4[,2]))
# # write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

### create a source map ###
plate1 <- digest[ , c(2, 9, 10)]


### COMPARE THE PLATEMAP TO THE GOOGLE SHEET TO MAKE SURE THERE ARE NO DIFFERENCES ###

# add wells and plate to database after the fact - list has already been made

# # if starting from a pre-existing file
# # read digest platemap_list into R
# digests <- "data/D2511-D2606list.csv"
# name <- substr(digests, 6, 16)
# diglist <- read.csv(digests, row.names = 1)

# if continuing code from above
diglist <- plate1
name <- paste(plate1[1,3], "-", plate1[nrow(plate1), 3], sep = "")
# 
# if more than one plate
diglist <- plate2
name <- paste(plate2[1,3], "-", plate2[nrow(plate2), 3], sep = "")

# diglist <- plate3
# name <- paste(plate3[1,3], "-", plate3[nrow(plate3), 3], sep = "")

# diglist <- plate4
# name <- paste(plate4[1,3], "-", plate4[nrow(plate4), 3], sep = "")


# create a column of Wells
diglist$wells <- paste(diglist$Row, diglist$Col, sep = "")

# create a column of Platenames
diglist$plate <- name

# Upload results to database ----------------------------------------------

### THIS STEP PULLS IN ALL OF THE DIGEST TABLE, ADDS THE QUANT DATA, AND THEN OVERWRITES ALL OF THE DIGEST TABLE WITH A NEW ONE CONTAINING THE NEW DATA, PROCEED WITH ***CAUTION*** Create the csv backup table in case you overwrite something by accident. ###

# Retrieve the digest data from the database using dplyr
suppressWarnings(digest <- labor %>% tbl("digest") %>% collect())
write.csv(digest, file = paste(Sys.time(), "digestbackup.csv", sep = ""))
  
  # add new quant data to existing data
  # for testing only quant$quant <- 8.008
  # which(digest_new$digest_id == "D3253")
  # digest_new$quant[3254] <- NA
  
  digest_new <- digest # make a copy of the original database table just in case something goes wrong
  
  digest_new$well <- ifelse(is.na(digest_new$well), diglist$well[match(digest_new$digest_id, diglist$ID)], digest_new$well)
  digest_new$plate <- ifelse(is.na(digest_new$plate), diglist$plate[match(digest_new$digest_id, diglist$ID)], digest_new$plate)
  
  # append to the data in the database using RMySQL
  library(RMySQL)
  labors <- dbConnect(MySQL(), dbname="Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)
  
  # Send data to database
  dbWriteTable(labors,"digest",data.frame(digest_new), row.names = FALSE, overwrite = TRUE)
  
  dbDisconnect(labors)
  rm(labors)
  
  rm(digest, digest_new, diglist, plate1, platemap1, first, last, name, i)
  
