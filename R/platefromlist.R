# a function to make a platemap from list

platemap <- function(x){
list <- read.csv(x, stringsAsFactors = F, row.names = 1)  
first <- list$ID[1]
last <- list$ID[nrow(list)]
list$ID <- as.character(list$ID)
platemap <- as.matrix(reshape2::acast(list,list[,1] ~ list[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))
print(platemap)
}


