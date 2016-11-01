# a script for prepping extractions and importing them into the database

# enter the interval of sample numbers to be extracted
span <- 95:188

# make a list of sample IDs in the order they are going to be extracted
sampID <- paste("APCL16_", formatC(span, width = 3, format = "d", flag = "0"), sep = "")

# insert the negative controls
sampID[95:96] <- "XXXX"

# add structure to assign order
rwnme <- 1:96

# put the samples in order of extraction (with negative controls inserted)

str1 <- cbind(rwnme[1:11], sampID[1:11])
str2 <- cbind(rwnme[12], sampID[95]) # because the first blank is in the 12th position
str3 <- cbind(rwnme[13:60], sampID[12:59])
str4 <- cbind(rwnme[61], sampID[96]) # because the 2nd blank is in the 61st position
str5 <- cbind(rwnme[62:96], sampID[60:94])

# and stick all of the rows together
extr <- data.frame(rbind(str1, str2, str3, str4, str5))

# add the date of extraction
extr$date <- as.Date("2016-09-06")

# add the method
extr$method <- "DNeasy 96"

# add the final volume after elution
extr$final_vol <- 200

names(extr) <- c("number", "sample_ID", "date", "method", "final_vol")
# fix extraction numbers so the order of extraction numbers matches the order of sample IDs
extr$number <- NULL
extr$number <- as.integer(1:96)

# make a plate map of sample IDs (for knowing where to place fin clips)
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, extr$sample_ID)
names(platelist) <- c("Row", "Col", "ID")
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]), value.var = platelist$ID)
write.csv(platemap, file = paste(Sys.Date(), "extract_map.csv", sep = ""))
# print this platemap and use to place fin clips in wells

# add well and plate data to extr table
platelist$well <- paste(platelist$Row, platelist$Col, sep = "")
platelist <- platelist[ , c("well", "ID")]
extr <- left_join(extr, platelist, by = c("sample_ID" = "ID"), copy = T)


### ONLY DO THIS ONCE ### generate extract numbers for database

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# get the last number used for extract
suppressWarnings(n <- data.frame(labor %>% tbl("extraction") %>% summarize(n())))
x <- n[1,]
extr$number <- paste("E", (extr$number + x), sep = "")
extr$plate <- paste(extr$number[1], "-", extr$number[nrow(extr)], sep = "")




# # edit the plate reader document so that it can be imported - delete header/footer, open in excel, check columns and save as csv
# # import plate reader results for quantificaiton
# pr <- read.csv("data/20160908_plate3.csv", stringsAsFactors = F, header = T)
# 
# # # add extract numbers (this plate contains the results for E2968-2975 plus others not on this current plate)
# # 
# # # remove rows for non-plate results
# # pr <- pr[1:8,]
# # # add extract numbers
# # pr$number <- 2968:2975
# # pr$number <- paste("E", pr$number, sep="")
# 
# pr2 <- read.csv("data/20160908_plate2.csv", stringsAsFactors = F)
# 
# pr2$number <- 3072:3159
# pr2$number <- paste("E", pr2$number, sep="")
# names(pr2) <- c("Sample", "Wells", "Value", "R", "Result", "MeanResult", "SD", "CV", "Dilution", "quant","number")
# 
# 
# extr1 <- merge(extr, pr, by.x = "number", by.y = "extraction_ID", all.x = T)
# extr1 <- extr1[1:8,]
# extr2 <- merge(extr, pr2[ , 10:11], by.x = "number", by.y = "number", all.x = T)
# extr2 <- extr2[9:96,]
# 
# extr <- rbind(extr1,extr2)

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




