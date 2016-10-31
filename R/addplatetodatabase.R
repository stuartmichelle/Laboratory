# add wells and plate to database after the fact

# read digest platemap_list into R
digests <- "data/D3247-D3339list.csv"

diglist <- read.csv(digests, row.names = 1)

# create a column of Wells
diglist$wells <- paste(diglist$Row, diglist$Col, sep = "")

# create a column of Platenames
diglist$plate <- "D3247-D3339"

# Upload results to database ----------------------------------------------

### THIS STEP PULLS IN ALL OF THE DIGEST TABLE, ADDS THE QUANT DATA, AND THEN OVERWRITES ALL OF THE DIGEST TABLE WITH A NEW ONE CONTAINING THE NEW DATA, PROCEED WITH ***CAUTION*** ###

# Retrieve the digest data from the database using dplyr
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# pull in all of the digest data
suppressWarnings(digest <- labor %>% tbl("digest") %>% collect())

# add new quant data to existing data
# for testing only quant$quant <- 8.008
# which(digest_new$digest_id == "D3253")
# digest_new$quant[3254] <- NA

digest_new <- digest # make a copy of the original database table just in case something goes wrong

digest_new$well <- NA
digest_new$plate <- NA
digest_new$well <- ifelse(is.na(digest_new$well), diglist$well[match(digest_new$digest_id, diglist$ID)], digest_new$wells)
digest_new$plate <- ifelse(is.na(digest_new$plate), diglist$plate[match(digest_new$digest_id, diglist$ID)], digest_new$plate)

# append to the data in the database using RMySQL
library(RMySQL)
labors <- dbConnect(MySQL(), host="amphiprion.deenr.rutgers.edu", user="michelles", password="larvae168", dbname="Laboratory", port=3306)

# Send data to database
dbWriteTable(labors,"digest",data.frame(digest_new), row.names = FALSE, overwrite = TRUE)

dbDisconnect(labors)
rm(labors)
