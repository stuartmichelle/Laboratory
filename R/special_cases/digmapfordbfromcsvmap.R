# pull the csv plate maps into R and prep them to be uploaded to database

# pull in the map
sheet <- read.csv("data/D3247-D3339map.csv", as.is = T)
  
# rename the columns
colnames(sheet) <- c("Row", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12")

#remove any blank rows
sheet <- sheet[!is.na(sheet$Row), ]

# take only the first 8 rows
sheet <- sheet[1:8, ]

# convert wide data to long data
data <- reshape2::melt(sheet, id.vars = "Row", variable.name = "Col", value.name = "Sample")

# remove any rows that do not contain samples
data <- data[!is.na(data$Sample), ]

# # if the plate map contains sample_ids as well as lab_ids (example APCL13_225D0342), remove the sample ID from the lab ID, want only lab ID left (ex: D0342)
# for (j in 1:nrow(data)){
#     if (nchar(data$Sample[j]) == 14){
#       data$Sample[j] <- paste(substr(data$Sample[j], 11, 11), "0", substr(data$Sample[j], 12,14), sep = "")
#     }
#     if (nchar(data$Sample[j]) == 15){
#       data$Sample[j] <- substr(data$Sample[j], 11, 15)
#     }
#     if (nchar(data$Sample[j]) == 18){
#       data$Sample[j] <- substr(data$Sample[j], 14, 18)
#     }
#     if (nchar(data$Sample[j]) == 10){
#       data$Sample[j] <- substr(data$Sample[j], 6, 10)
#     }
#     if (nchar(data$Sample[j]) == 17){
#       data$Sample[j] <- substr(data$Sample[j], 13, 17)
#     }
#   }
  
# sort the plate by lab ID and name the plate by the first and last sample
data <- arrange(data, Sample)
data$Plate <- paste(data$Sample[1], "-", data$Sample[nrow(data)], sep = "")

# write.csv(data, file = paste("data/", data$Plate[1], "_list.csv", sep = ""), row.names = F)

# pull in all of the  data from the database
# suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

suppressWarnings(samples <- labor %>% tbl("digest") %>% collect())

# create backup file of database table
write.csv(samples, file = paste(Sys.time(), "digestbackup.csv"), row.names = F)

# join the row and column into a well
data$well <- paste(data$Row, data$Col, sep = "")
data$Row <- NULL
data$Col <- NULL
colnames(data) <- c("digest_id", "new_plate", "new_well")

# join the new plate data to the database data
final <- left_join(samples, data, by = "digest_id")

# have to smoosh the new columns into the old columns
for (i in 1:nrow(final)){
  if (!is.na(final$new_well[i])){
    final$well[i] <- final$new_well[i]
    final$plate[i] <- final$new_plate[i]
  }
}
final$new_well <- NULL
final$new_plate <- NULL


# append to the data in the database using RMySQL
library(RMySQL)
labors <- dbConnect(MySQL(), dbname="Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL )


# Send data to database
dbWriteTable(labors,"digest",data.frame(final), row.names = FALSE, overwrite = TRUE)

dbDisconnect(labors)
gc(labor)
rm(labors, labor)

