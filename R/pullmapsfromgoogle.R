# pull the google sheets plate maps into R and prep them to be uploaded to database


# googlesheets::gs_auth(new_user = TRUE) # run this if having authorization problems
mykey = '193Jk0nP3l3Y5cMYAArHV80q9zlEOHBEmE6NOasjjZB0' # the key for Plate Maps File
platemap <- googlesheets::gs_key(mykey)
sheetlist <- googlesheets::gs_ws_ls(platemap)

final <- data.frame(Row = NA, Col = NA, Sample = NA, Plate = NA)

for (i in 8:length(sheetlist)){
  sheet <- googlesheets::gs_read(platemap, ws = sheetlist[i])
  colnames(sheet) <- c("Row", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12")
  sheet <- sheet[1:8, ]
  data <- reshape2::melt(sheet, id.vars = "Row", variable.name = "Col", value.name = "Sample")
  for (j in 1:nrow(data)){
    if (nchar(data$Sample[j]) == 14){
      data$Sample[j] <- paste(substr(data$Sample[j], 11,11), "0", substr(data$Sample[j], 12,14), sep = "")
    }
    if (nchar(data$Sample[j]) == 14){
      data$Sample[j] <- substr(data$Sample[j], 11,15)
    }
  }
  data$Plate <- paste(data$Sample[1], "-", data$Sample[nrow(data)], sep = "")
  final <- rbind(final, data)
  Sys.sleep(20)
}


