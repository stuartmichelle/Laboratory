# this script takes the samples from step 1 that have already been extracted 
# and quantified and prepares them for import into the database

# import data from step 1 (prep_samples_for_extraction.R)
extrfile <- "data/2016-11-02_extract_list.csv"
extr <- read.csv(extrfile, stringsAsFactors = F)

# add the date of extraction
extr$date <- as.Date("2016-09-06")

# add the method
extr$method <- "DNeasy 96"

# add the final volume after elution
extr$final_vol <- 200

# add temporary extraction number
extr$number <- as.integer(1:96)

# add well and plate data to extr table
extr$well <- paste(extr$Row, extr$Col, sep = "")

### ONLY DO THIS ONCE ### generate extract numbers for database

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# get the last number used for extract
suppressWarnings(n <- data.frame(labor %>% tbl("extraction") %>% summarize(n())))
x <- n[1,]
extr$number <- paste("E", (extr$number + x), sep = "")
extr$plate <- paste(extr$number[1], "-", extr$number[nrow(extr)], sep = "")


# Create a plate map of quantification of extracts -------------------------

# because one row of the quantification plate is taken up by standards so one column from 
# the plate to be quantified has to be moved to a second plate (which could actually be 
# a third or more plate)

# WHICH COLUMN OF THE SECOND PLATE IS THE FIRST COLUMN IN?
extracol <- 2

# find the samples in the plate and their well locations

# split Col 1 into a second plate 
extr2 <- extr[(extr$Col == 1), ]
extr1 <- extr[(extr$Col != 1), ]

# correct the locations of the second list to account for being moved to second plate
extr2$Col <- extracol

# Read in quantification results ------------------------------------------

# read in plate reader data for the first plate
platefile1 = "data/20160919_plate1.txt"
colsinplate1 = 2:12 # is this a full plate?

strs <- readLines(platefile1, skipNul = T)
linestoskip = (which(strs == "Group: Unk_Dilution"))

dat1 <- read.table(text = strs,  skip = linestoskip, sep = "\t", fill = T, header = T, stringsAsFactors = F)

# remove footer rows
dat1 <- dat1[1:(which(dat1$Sample == "Group Summaries")-1), ]

# read in names for the samples
quant1 <- dplyr::left_join(dat1, dig1, by = c("Wells" = "well"))
quant1 <- quant1[ , c("ID", "AdjResult")]
colnames(quant1) <- c("extraction_id", "quant")

# repeat for second plate
platefile2 = "data/20160919_plate2.txt"
colsinplate2 = 1 # or is this just the first column of the plate?

strs <- readLines(platefile2, skipNul = T)
linestoskip = (which(strs == "Group: Unk_Dilution"))

dat2 <- read.table(text = strs,  skip = linestoskip, sep = "\t", fill = T, header = T, stringsAsFactors = F)

# remove footer rows
dat2 <- dat2[1:(which(dat2$Sample == "Group Summaries")-1), ]

# read in names for the samples
quant2 <- dplyr::left_join(dat2, dig2, by = c("Wells" = "well"))
quant2 <- quant2[ , c("ID", "AdjResult")]
colnames(quant2) <- c("extraction_id", "quant")

# join the 2 results lists
quant <- rbind(quant1, quant2)

# remove any empty wells
quant <- quant[!is.na(quant$extraction_id), ]

# Upload results to database ----------------------------------------------

### THIS STEP PULLS IN ALL OF THE DIGEST TABLE, ADDS THE QUANT DATA, AND THEN OVERWRITES ALL OF THE DIGEST TABLE WITH A NEW ONE CONTAINING THE NEW DATA, PROCEED WITH ***CAUTION*** ###

# Retrieve the digest data from the database using dplyr

# pull in all of the digest data
suppressWarnings(extractiontbl <- labor %>% tbl("extraction") %>% collect())

# add new quant data to existing data
# for testing only quant$quant <- 8.008
# which(digest_new$digest_id == "D3253")
# digest_new$quant[3254] <- NA

extr_new <- extractiontbl # make a copy of the original database table just in case something goes wrong

extr_new$quant <- ifelse(is.na(extr_new$quant), quant$quant[match(extr_new$extraction_id, quant$extraction_id)], extr_new$quant)

# append to the data in the database using RMySQL
library(RMySQL)
labors <- dbConnect(MySQL(), host="amphiprion.deenr.rutgers.edu", user="michelles", password="larvae168", dbname="Laboratory", port=3306)

# Send data to database
dbWriteTable(labors,"extraction",data.frame(extr_new), row.names = FALSE, overwrite = )

dbDisconnect(labors)
rm(labors)








extr$dna <- extr$final_vol * extr$quant * 0.001

write.csv(extr, file = paste(Sys.Date(), "extract_list.csv", sep = ""))

# import the extract_list into the database

# make a plate map of extraction IDs (for a record of where extractions are stored)
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, extr[,1])
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))




