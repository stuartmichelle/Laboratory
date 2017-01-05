

# make a list of columns and rows (the locations for the platemap only)
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))

# connect to database
suppressMessages(library(dplyr))
source("R/conlabor.R")
source("R/makeplate.R")
labor <- conlabor()

# Retrieve the data from the database using dplyr and back it up
suppressWarnings(ligation <- labor %>% tbl("ligation") %>% collect())
write.csv(ligation, file = paste("data/", Sys.time(), "_ligationbackup.csv", sep = ""))

# # define range of pools if you are going to do the full range
# end <- max(ligation$pool)
# end <- as.numeric(substr(end, 2,4))

liglist <- data.frame()
# pool1 <- "P016"
# pool2 <- "P019"
pool1 <- "P017"
pool2 <- "P018"

# for (i in c(53, 55, 57, 59, 61, 63, 65, 67, 69, 71)){

  # pool1 <- paste("P", formatC(i, 2, flag = 0), sep = "")
  # pool2 <- paste("P", formatC(i+1, 2, flag = 0), sep = "")
  ID <- ligation[ligation$pool == pool1 | ligation$pool == pool2, 1]
  ID <- ID[order(ID$ligation_id), ]
  plate1 <- makeplate()
  
  lig <- plate1
  name <- paste(plate1[1,3], "-", plate1[nrow(plate1), 3], sep = "")
  # create a column of Wells
  lig$wells <- paste(lig$Row, lig$Col, sep = "")
  # create a column of Platenames
  lig$plate <- name
  
  # add to the dataframe 
  liglist <- rbind(liglist, lig)
  
}

# Upload results to database ----------------------------------------------

### THIS STEP PULLS IN ALL OF THE DIGEST TABLE, ADDS THE QUANT DATA, AND THEN OVERWRITES ALL OF THE DIGEST TABLE WITH A NEW ONE CONTAINING THE NEW DATA, PROCEED WITH ***CAUTION*** Create the csv backup table in case you overwrite something by accident. ###

# match wells from plates above to wells in database
  ligation$well <- ifelse(is.na(ligation$well), liglist$well[match(ligation$ligation_id, liglist$ID)], ligation$well)

# match wells from plates above to wells in database
  ligation$plate <- ifelse(is.na(ligation$plate), liglist$plate[match(ligation$ligation_id, liglist$ID)], ligation$plate)
  
  # append to the data in the database using RMySQL
  library(RMySQL)
  labors <- dbConnect(MySQL(), dbname="Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)
  
  # Send data to database
  dbWriteTable(labors,"ligation",data.frame(ligation), row.names = FALSE, overwrite = TRUE)
  
  dbDisconnect(labors)
  rm(labors)
  
  rm(ID, lig, ligation, liglist, plate, plate1, platemap1)
  
  
