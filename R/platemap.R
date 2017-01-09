# a script to make platemaps from db info

# from db
source("R/makeplatedb.R")
x <- "D3192-D3246"
plate <- mkplatedb(x)
plate <- as.data.frame(plate)
plate <- plate[, c(2, 3, 1)]
plate$col <- as.numeric(plate$col)
platemap <- as.matrix(reshape2::acast(plate,plate[,1] ~ plate[,2]))
write.csv(platemap, file = paste("data/", x, "_map.csv", sep = ""))

