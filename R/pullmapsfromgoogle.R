# pull the google sheets plate maps into R and prep them to be uploaded to database


# googlesheets::gs_auth(new_user = TRUE) # run this if having authorization problems
mykey = '193Jk0nP3l3Y5cMYAArHV80q9zlEOHBEmE6NOasjjZB0' # the key for Plate Maps File
platemap <- googlesheets::gs_key(mykey)
sheetlist <- googlesheets::gs_ws_ls(platemap)

final <- data.frame(Row = NA, Col = NA, Sample = NA, Plate = NA)

for (i in 66:length(sheetlist)){
  sheet <- googlesheets::gs_read(platemap, ws = sheetlist[i])
  colnames(sheet) <- c("Row", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12")
  sheet <- sheet[1:8, ]
  data <- reshape2::melt(sheet, id.vars = "Row", variable.name = "Col", value.name = "Sample")
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
write.csv(final, file = "fullplatelist1.csv", row.names = F)


# fix naming mistakes
for (j in 1:nrow(final)){
  if (nchar(final$Sample[j]) == 14){
    final$Sample[j] <- paste(substr(final$Sample[j], 11, 11), "0", substr(final$Sample[j], 12,14), sep = "")
  }
  if (nchar(final$Sample[j]) == 15){
    final$Sample[j] <- substr(final$Sample[j], 11, 15)
  }
  if (nchar(final$Sample[j]) == 18){
    final$Sample[j] <- substr(final$Sample[j], 14, 18)
  }
  if (nchar(final$Sample[j]) == 10){
    final$Sample[j] <- substr(final$Sample[j], 6, 10)
  }
  if (nchar(final$Sample[j]) == 17){
    final$Sample[j] <- substr(final$Sample[j], 13, 17)
  }
}

extracts <- final[1,]
extracts[1, ] <- NA

digests <- final[1, ]
digests[1, ] <- NA

ligs <- final[1, ]
ligs[1, ] <- NA

final_backup <- final


# split out extracts, digests, ligations and junk
for (i in 1:nrow(final)){
  if (!is.na(final$Sample[i]) & substr(final$Sample[i], 1, 1) == "E"){
    extracts[i, ] <- final[i,]
    final[i, ] <- NA
  }
}
extracts <- extracts[!is.na(extracts$Sample), ]

final$Sample[1] <- "E1253"
final$Sample[2] <- "E1254"
final$Sample[3] <- "E2579"
final$Sample[2] <- "E2430"

extracts[nrow(extracts)+1, ] <- final[1, ]
extracts[nrow(extracts)+1, ] <- final[2, ]
extracts[nrow(extracts)+1, ] <- final[3, ]

for (i in 1:nrow(final)){
  if (!is.na(final$Sample[i]) & substr(final$Sample[i], 1, 1) == "D"){
    digests[i, ] <- final[i,]
    final[i, ] <- NA
  }
}
digests <- digests[!is.na(digests$Sample), ]

for (i in 1:nrow(final)){
  if (!is.na(final$Sample[i]) & substr(final$Sample[i], 1, 1) == "L"){
    ligs[i, ] <- final[i,]
    final[i, ] <- NA
  }
}
ligs <- ligs[!is.na(ligs$Sample), ]

final <- final[!is.na(final$Row), ]

write.csv(extracts, file = "fullextractlist.csv", row.names = F)
write.csv(digests, file = "fulldigestlist.csv", row.names = F)
write.csv(ligs, file = "fullligationlist.csv", row.names = F)
write.csv(final_backup, file = "fullplatelist.csv", row.names = F)

# test <- read.csv("fullextractlist.csv")

