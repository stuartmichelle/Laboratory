# a script for prepping extractions and importing them into the database

# define the interval of sample numbers to be extracted
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

# make a plate map
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, extr[,2])
names(platelist) <- c("Row", "Col", "ID")
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
write.csv(platemap, file = paste(Sys.Date(), "extract_map.csv", sep = ""))

### ONLY DO THIS ONCE ### import new rows into database

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

n <- data.frame(labor %>% tbl("extraction") %>% summarize(n()))
x <- n[1,]
extr$number <- paste("E", as.integer(extr$number) + x, sep = "")

write.csv(extr, file = paste(Sys.Date(), "extract_list.csv", sep = ""))


