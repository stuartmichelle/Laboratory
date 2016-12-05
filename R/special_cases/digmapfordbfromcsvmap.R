# pull the csv plate maps into R and prep them to be uploaded to database

final <- data.frame(Row = NA, Col = NA, Sample = NA, Plate = NA)


  sheet <- read.csv("data/D3247-D3339map.csv", as.is = T)
  colnames(sheet) <- c("Row", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12")
  sheet <- sheet[!is.na(sheet$Row), ]
  sheet <- sheet[1:8, ]
  data <- reshape2::melt(sheet, id.vars = "Row", variable.name = "Col", value.name = "Sample")
  data <- data[!is.na(data$Sample), ]
  for (j in 1:nrow(data)){
    if (nchar(data$Sample[j]) == 14){
      data$Sample[j] <- paste(substr(data$Sample[j], 11, 11), "0", substr(data$Sample[j], 12,14), sep = "")
    }
    if (nchar(data$Sample[j]) == 15){
      data$Sample[j] <- substr(data$Sample[j], 11, 15)
    }
    if (nchar(data$Sample[j]) == 18){
      data$Sample[j] <- substr(data$Sample[j], 14, 18)
    }
    if (nchar(data$Sample[j]) == 10){
      data$Sample[j] <- substr(data$Sample[j], 6, 10)
    }
    if (nchar(data$Sample[j]) == 17){
      data$Sample[j] <- substr(data$Sample[j], 13, 17)
    }
  }
  data$Plate <- paste(data$Sample[1], "-", data$Sample[nrow(data)], sep = "")
  final <- rbind(final, data)
  Sys.sleep(20)
}
# write.csv(final, file = "fullplatelist1.csv", row.names = F)


# # fix naming mistakes
# final$Sample[which(final$Sample == "APCL15_3733511E2579")] <- "E2579"
# final$Sample[which(final$Sample == "XE1253")] <- "E1253"
# final$Sample[which(final$Sample == "XE1254")] <- "E1254"
# final$Sample[which(final$Sample == "20430")] <- "E2430"
# final$Sample[which(final$Sample == "these columns were combined during extraction")] <- NA
# final$Sample[which(final$Sample == "BALANCE/neg control")] <- NA
# final$Plate[which(final$Plate == "E1962-BALANCE/neg control")] <- "E1962-E2043"

final <- final[!is.na(final$Sample), ]

# write.csv(final, file = "fullplatelist1.csv", row.names = F)
# final <- read.csv("fullplatelist1.csv", stringsAsFactors = F)
# 
# extracts <- final[1,]
# extracts[1, ] <- NA
# 
# digests <- final[1, ]
# digests[1, ] <- NA
# 
# final_backup <- final
# 
# 
# # split out extracts, digests, ligations and junk
# for (i in 1:nrow(final)){
#   if (substr(final$Sample[i], 1, 1) == "E"){
#     extracts[i, ] <- final[i,]
#     final[i, ] <- NA
#   }
# }
# extracts <- extracts[!is.na(extracts$Sample), ]
# 
# for (i in 1:nrow(final)){
#   if (!is.na(final$Sample[i]) & substr(final$Sample[i], 1, 1) == "D"){
#     digests[i, ] <- final[i,]
#     final[i, ] <- NA
#   }
# }
# digests <- digests[!is.na(digests$Sample), ]
# 
# for (i in 1:nrow(final)){
#   if (!is.na(final$Sample[i]) & substr(final$Sample[i], 1, 1) == "L"){
#     ligs[i, ] <- final[i,]
#     final[i, ] <- NA
#   }
# }
# ligs <- ligs[!is.na(ligs$Sample), ]
# 
# final <- final[!is.na(final$Row), ]
# 
# write.csv(extracts, file = "fullextractlist.csv", row.names = F)
# write.csv(digests, file = "fulldigestlist.csv", row.names = F)
# write.csv(ligs, file = "fullligationlist.csv", row.names = F)
# write.csv(final_backup, file = "fullplatelist.csv", row.names = F)
# 
# # test <- read.csv("fullextractlist.csv")
# 
# # look for errors in  plate names
# issue <- extracts[which(nchar(extracts$Plate) != 11),]
# issue <- digests[which(nchar(digests$Plate) != 11),]

# pull in all of the  data
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

suppressWarnings(samples <- labor %>% tbl("digest") %>% collect())

# create backup file of database table
write.csv(samples, file = paste(Sys.time(), "digestbackup.csv"), row.names = F)

# open the extract list containing wells and plates
# wells <- read.csv("data/fulldigestlist.csv", stringsAsFactors = F)
wells <- final
wells$well <- paste(wells$Row, wells$Col, sep = "")
wells$Row <- NULL
wells$Col <- NULL
# colnames(wells) <- c("digest_id", "plate", "well")
colnames(wells) <- c("digest_id", "new_plate", "new_well")

# try writing out a csv and importing it as an update
final2 <- left_join(wells, samples, by = "digest_id")
final2$well <- NULL
final2$plate <- NULL
colnames(final2) <- c("digest_id", "plate", "well",  "extraction_id", "date", "vol_in",    "ng_in",     "enzymes",   "final_vol", "quant","DNA_ng",    "notes",     "correction" ,   "corr_message" , "corr_editor", "corr_date" )

write.csv(final2, file = "data/digestsfordb.csv", row.names = F)

# join the well data to the database data
final1 <- left_join(samples, wells, )

for (i in 1:nrow(final1)){
  if (!is.na(final1$new_well[i])){
    final1$well[i] <- final1$new_well[i]
    final1$plate[i] <- final1$plate[i]
  }
}


# append to the data in the database using RMySQL
library(RMySQL)
labors <- dbConnect(MySQL(), host="amphiprion.deenr.rutgers.edu", user="michelles", password="larvae168", dbname="Laboratory", port=3306)

# Send data to database
dbWriteTable(labors,"digest",data.frame(final), row.names = FALSE, overwrite = TRUE)

dbDisconnect(labors)
rm(labors)
