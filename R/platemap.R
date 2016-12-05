# a script to make platemaps

# make a list of columns and rows (the locations for the platemap only)
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))

# import lab ids for the plate
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# # pull out sample IDs by date of procedure
# samples <- data.frame(labor %>% tbl("extraction") %>% filter(date == '2016-09-06'), stringsAsFactors = F)


# find date of desired sample
digest <- labor %>% tbl("digest") %>% select(digest_id, date) %>% filter(date == "2016-09-18")
# digest <- labor %>% tbl("digest") %>% select(digest_id, date) %>% filter(digest_id == S1_first)
dig <- collect(digest)
# get plates for that day
# 
# # remove quotes from string rows
# samples$extraction_ID <- substr(samples$extraction_ID,2,6)
# samples$sample_ID <- substr(samples$sample_ID, 2,11)
samples <- dig

# # cut down to the number of rows needed
# i <- nrow(samples)
# if(i < 96){
#   plate <- plate[1:i,]
# }

# if plate is smaller than 96,
# plate1 <- cbind(plate, samples[ , 1])

plate1 <- cbind(plate, samples[1:96,1])
names(plate1) <- c("Row", "Col", "ID")
first <- plate1$ID[1]
last <- plate1$ID[nrow(plate1)]
write.csv(plate1, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate1$ID <- as.character(plate1$ID)
platemap <- as.matrix(reshape2::acast(plate1,plate1[,1] ~ plate1[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))


plate2 <- cbind(plate, samples[97:192,1])
names(plate2) <- c("Row", "Col", "ID")
first <- plate2$ID[1]
last <- plate2$ID[nrow(plate2)]
write.csv(plate2, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate2$ID <- as.character(plate2$ID)
platemap <- as.matrix(reshape2::acast(plate2,plate2[,1] ~ plate2[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

plate3 <- cbind(plate, digest[193:288,1])
names(plate3) <- c("Row", "Col", "ID")
first <- plate3$ID[1]
last <- plate3$ID[nrow(plate3)]
write.csv(plate3, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate3$ID <- as.character(plate3$ID)
platemap <- as.matrix(reshape2::acast(plate3,plate3[,1] ~ plate3[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

plate4 <- cbind(plate, digest[289:384,1])
names(plate4) <- c("Row", "Col", "ID")
first <- plate4$ID[1]
last <- plate4$ID[nrow(plate4)]
write.csv(plate4, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate4$ID <- as.character(plate4$ID)
platemap <- as.matrix(reshape2::acast(plate4,plate4[,1] ~ plate4[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))


# plate1 <- cbind(plate, extract[1:96,1])
# names(plate1) <- c("Row", "Col", "ID")
# write.csv(plate1, file = paste(Sys.Date(), "plate1.csv", sep = ""))
# first <- plate1$ID[1]
# last <- plate1$ID[nrow(plate1)]
# # plate1$ID <- as.character(plate1$ID)
# # platemap <- as.matrix(reshape2::acast(plate1,plate1[,1] ~ plate1[,2]))
# # write.csv(platemap, file = paste(first, "-",last, ".csv"))
# 
# plate2 <- cbind(plate, extract[97:192, 1])
# names(plate2) <- c("Row", "Col", "ID")
# write.csv(plate2, file = paste(Sys.Date(), "plate2.csv", sep = ""))
# first <- plate2[1,3]
# last <- (plate2$ID[nrow(plate2)])
# plate2$ID <- as.character(plate2$ID)
# platemap <- as.matrix(reshape2::acast(plate2,plate2[,1] ~ plate2[,2]))
# write.csv(platemap, file = paste(first, "-",last, ".csv"))
# 
# plate3 <- cbind(plate, extract[193:288, 1])
# names(plate3) <- c("Row", "Col", "ID")
# write.csv(plate3, file = paste(Sys.Date(), "plate3.csv", sep = ""))
# first <- plate3[1,3]
# last <- (plate3$ID[nrow(plate3)])
# plate3$ID <- as.character(plate3$ID)
# platemap <- as.matrix(reshape2::acast(plate3,plate3[,1] ~ plate3[,2]))
# write.csv(platemap, file = paste(first, "-",last, ".csv"))
# 
# plate4 <- cbind(plate, extract[289:384, 1])
# names(plate4) <- c("Row", "Col", "ID")
# write.csv(plate4, file = paste(Sys.Date(), "plate4.csv", sep = ""))
# first <- plate4[1,3]
# last <- (plate4$ID[nrow(plate4)])
# plate4$ID <- as.character(plate4$ID)
# platemap <- as.matrix(reshape2::acast(plate4,plate4[,1] ~ plate4[,2]))
# write.csv(platemap, file = paste(first, "-",last, ".csv"))

