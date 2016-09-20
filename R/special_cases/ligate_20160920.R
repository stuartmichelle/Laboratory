# plan a ligation run

# run the find samples code first to generate a not_ligated table
not_ligated <- data.frame(read.csv("2016-09-20_need_ligate.csv"))

# sort by quantification
not_ligated <- not_ligated[order(not_ligated$quant), ]

# identify samples that can be ligated at different ng
twohundy <- not_ligated[which(not_ligated$quant > 9.45), ]
nrow(twohundy) # 48
not_ligated$DNA[not_ligated$quant > 9.45] <- 200

onefifty <- not_ligated[which(not_ligated$quant > 6.75 & not_ligated$quant <= 9.45), ]
nrow(onefifty) # 9

onehundy <- not_ligated[which(not_ligated$quant > 4.5 & not_ligated$quant <= 9.45), ]
nrow(onehundy) #37

sevfive <- not_ligated[which(not_ligated$quant > 3.85 & not_ligated$quant <= 9.45), ]
nrow(sevfive) # 48
not_ligated$DNA[not_ligated$quant > 3.85 & not_ligated$quant <= 9.45] <- 75

fourty <- not_ligated[which(not_ligated$quant > 2.16 & not_ligated$quant <= 3.85), ]
nrow(fifty) #48
not_ligated$DNA[not_ligated$quant > 2.16 & not_ligated$quant <= 3.85] <- 40

twenfive <- not_ligated[which(not_ligated$quant > 1.15 & not_ligated$quant <= 2.16), ]
nrow(twenfive) #34

ten <- not_ligated[which(not_ligated$quant > 0.543 & not_ligated$quant <= 2.16), ]
nrow(ten) #48
not_ligated$DNA[not_ligated$quant > 0.543 & not_ligated$quant <= 2.16] <- 10

# remove samples that will not be ligated in this batch
not_ligated <- not_ligated[!is.na(not_ligated$DNA), ]

# clean up environment
rm(fourty, onehundy, onefifty, sevfive, ten, twenfive, twohundy)

# calculate volume in to 3 digits
not_ligated$vol_in <- as.numeric(formatC(not_ligated$DNA/not_ligated$quant, digits = 3))

# check the max and min to make sure the volumes are between 0.5 and 22.2
max(not_ligated$vol_in) # 21.1
min(not_ligated$vol_in) # 1.5

# add water
not_ligated$water <- as.numeric(formatC((22.2 - not_ligated$vol_in), digits = 3))

#remove unneeded columns
not_ligated <- not_ligated[ , c(2, 5, 10, 11, 12)]

# sort by DNA
not_ligated <- not_ligated[order(not_ligated$DNA), ]

# add ligation numbers
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)
n <- data.frame(labor %>% tbl("ligation") %>% summarize(n()))
x <- n[1,]
not_ligated$ligation_id <- 1:192
not_ligated$ligation_id <- paste("L", (not_ligated$ligation_id + x), sep = "")

# create a water plan
biomek_water <- not_ligated
biomek_water$sourceloc <- "P9"
biomek_water$destloc[1:96] <- "P12"
biomek_water$destloc[97:192] <- "P13"
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
biomek_water <- cbind(plate, biomek_water)
biomek_water$sourcewell <- paste(biomek_water$Row, biomek_water$Col, sep = "")
biomek_water$destwell <- biomek_water$sourcewell

#save it - ### ONLY WRITE THIS FILE ONCE ###
# write.csv(biomek_water, file = paste(Sys.Date(), "biomek_water.csv", sep = ""))

# create a sample plan
biomek_sample <- not_ligated
biomek_sample$destloc[1:96] <- "P12"
biomek_sample$destloc[97:192] <- "P13"
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
biomek_sample <- cbind(plate, biomek_sample)
biomek_sample$destwell <- paste(biomek_sample$Row, biomek_sample$Col, sep = "")
biomek_sample$Row <- NULL
biomek_sample$Col <- NULL

# find source wells

# first digest_ID is D2553, is on plate D2511-D2606
S1 <- read.csv("data/D2511-D2606list.csv", row.names = 1)
biomek_sample <- merge(biomek_sample, S1, by.x = "digest_id", by.y = "ID", all.x = T)
biomek_sample$sourcewell <- paste(biomek_sample$Row, biomek_sample$Col, sep = "")
biomek_sample$Row <- NULL
biomek_sample$Col <- NULL
S1 <- biomek_sample[which(biomek_sample$sourcewell != "NANA"), ]
dest <<- dest[which(dest$sourcewell == "NANA"), ]
dest <<- dest[order(dest$extraction_ID), ]



# split table into 2 plates
plate1 <- not_ligated[1:96, ]
plate2 <- not_ligated[97:192, ]



# create a platemap for first plate
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, plate1[,2])
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# create a platemap for second plate
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, plate2[,2])
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# create a source map for first plate
sourcelist <- cbind(plate, plate1[ , 1])
names(sourcelist) <- c("Row", "Col", "ID")
sourcelist$ID <- as.character(sourcelist$ID)
sourcemap <- as.matrix(reshape2::acast(sourcelist,sourcelist[,1] ~ sourcelist[,2]))
write.csv(sourcemap, file = paste("data/", Sys.Date(), "map.csv", sep = ""))

# create a source map for second plate
sourcelist <- cbind(plate, plate2[ , 1])
names(sourcelist) <- c("Row", "Col", "ID")
sourcelist$ID <- as.character(sourcelist$ID)
sourcemap <- as.matrix(reshape2::acast(sourcelist,sourcelist[,1] ~ sourcelist[,2]))
write.csv(sourcemap, file = paste("data/", Sys.Date(), "map.csv", sep = ""))


###PRINT OUT THE MAPS AND THINK ABOUT HOW TO MAKE A BIOMEK SOURCE FILE ###
##################################################################################
# After digest is complete, add additional info (enzymes, final vol, quant, DNA)

# create an import file for database
write.csv(need, file = paste("data/", Sys.Date(), "digestforimport.csv", sep = ""))
