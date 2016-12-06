# plate from list

# read in csv
list <- read.csv("../../myRcode/Laboratory/data/E0823-E0918list.csv", row.names = 1)

first <- list$ID[1]
last <- list$ID[nrow(list)]
list$ID <- as.character(list$ID)
platemap <- as.matrix(reshape2::acast(list,list[,1] ~ list[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))


