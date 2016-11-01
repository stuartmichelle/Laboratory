
# Create a plate map of quantification of digests -------------------------

# WHICH COLUMN OF THE SECOND PLATE IS THE FIRST COLUMN IN?
extracol <- 2

# Read digest platemap_list into R from database - find the samples in the plate and their well locations

# which plate are you looking for?
platename <- "D3247-D3339"

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

diglist <- labor %>% tbl("digest") %>% filter(plate == platename) %>% select(digest_id, well) %>% collect()

# separate out row from column in wells
diglist$Row <- substr(diglist$well, 1, 1)
diglist$Col <- substr(diglist$well, 2, 2)

# split Col 1 into a second plate 
dig2 <- diglist[(diglist$Col == 1), ]
dig1 <- diglist[(diglist$Col != 1), ]


# correct the locations of dig2 to account for being moved to second plate
dig2$Col <- extracol


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
colnames(quant1) <- c("digest_id", "quant")

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
colnames(quant2) <- c("digest_id", "quant")

# join the 2 results lists
quant <- rbind(quant1, quant2)

# remove any empty wells
quant <- quant[!is.na(quant$digest_id), ]

# Upload results to database ----------------------------------------------

### THIS STEP PULLS IN ALL OF THE DIGEST TABLE, ADDS THE QUANT DATA, AND THEN OVERWRITES ALL OF THE DIGEST TABLE WITH A NEW ONE CONTAINING THE NEW DATA, PROCEED WITH ***CAUTION*** ###

# Retrieve the digest data from the database using dplyr

# pull in all of the digest data
suppressWarnings(digest <- labor %>% tbl("digest") %>% collect())

# add new quant data to existing data
# for testing only quant$quant <- 8.008
# which(digest_new$digest_id == "D3253")
# digest_new$quant[3254] <- NA

digest_new <- digest # make a copy of the original database table just in case something goes wrong

digest_new$quant <- ifelse(is.na(digest_new$quant), quant$quant[match(digest_new$digest_id, quant$digest_id)], digest_new$quant)

# append to the data in the database using RMySQL
library(RMySQL)
labors <- dbConnect(MySQL(), host="amphiprion.deenr.rutgers.edu", user="michelles", password="larvae168", dbname="Laboratory", port=3306)

# Send data to database
dbWriteTable(labors,"digest",data.frame(digest_new), row.names = FALSE, overwrite = TRUE)

dbDisconnect(labors)
rm(labors)

