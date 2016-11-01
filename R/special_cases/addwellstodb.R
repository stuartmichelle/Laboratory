# add well and plate info to database

# Retrieve the  data from the database using dplyr

# pull in all of the  data
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

suppressWarnings(extract <- labor %>% tbl("extraction") %>% collect())

# open the extract list containing wells and plates
wells <- read.csv("fullextractlist.csv", stringsAsFactors = F)
wells$well <- paste(wells$Row, wells$Col, sep = "")
wells$Row <- NULL
wells$Col <- NULL

# join the well data to the database data
final <- left_join(extract, wells, by = c("extraction_id" = "Sample"))

# append to the data in the database using RMySQL
library(RMySQL)
labors <- dbConnect(MySQL(), host="amphiprion.deenr.rutgers.edu", user="michelles", password="larvae168", dbname="Laboratory", port=3306)

# Send data to database
dbWriteTable(labors,"extraction",data.frame(final), row.names = FALSE, overwrite = TRUE)

dbDisconnect(labors)
rm(labors)


# add well and plate info to database

# Retrieve the  data from the database using dplyr

# pull in all of the  data
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

suppressWarnings(samples <- labor %>% tbl("digest") %>% collect())

# create backup file of database table
write.csv(samples, file = paste(Sys.time(), "digestbackup.csv"), row.names = F)

# open the extract list containing wells and plates
wells <- read.csv("data/fulldigestlist.csv", stringsAsFactors = F)
wells$well <- paste(wells$Row, wells$Col, sep = "")
wells$Row <- NULL
wells$Col <- NULL

# join the well data to the database data
final <- left_join(samples, wells, by = c("digest_id" = "Sample"))

# append to the data in the database using RMySQL
library(RMySQL)
labors <- dbConnect(MySQL(), host="amphiprion.deenr.rutgers.edu", user="michelles", password="larvae168", dbname="Laboratory", port=3306)

# Send data to database
dbWriteTable(labors,"digest",data.frame(final), row.names = FALSE, overwrite = TRUE)

dbDisconnect(labors)
rm(labors)
