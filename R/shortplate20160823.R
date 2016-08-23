# a script for platemaps for the 2 extract plates that didn't fill all of the rows

# make a list of columns and rows (the locations for the platemap only)
plate <- data.frame( Row = rep(LETTERS[1:6], 12), Col = unlist(lapply(1:12, rep, 6)))

# remove the f rows from columns 8-12
plate <- plate[c(1:47, 49:53, 55:59, 61:65, 67:71), ]

# read in the current list of samples
plate1 <- read.csv("data/E2834-E2900list.csv", row.names = 1)

plate1 <- cbind(plate, plate1[ ,3])
names(plate1) <- c("Row", "Col", "ID")
first <- plate1$ID[1]
last <- plate1$ID[nrow(plate1)]
write.csv(plate1, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate1$ID <- as.character(plate1$ID)
platemap <- as.matrix(reshape2::acast(plate1,plate1[,1] ~ plate1[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))


# read in the current list of samples
plate2 <- read.csv("data/E2930-E2967list.csv", row.names = 1)

plate2 <- cbind(plate, plate2[ ,3])
names(plate2) <- c("Row", "Col", "ID")
first <- plate2$ID[1]
last <- plate2$ID[nrow(plate2)]
write.csv(plate2, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate2$ID <- as.character(plate2$ID)
platemap <- as.matrix(reshape2::acast(plate2,plate2[,1] ~ plate2[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))
