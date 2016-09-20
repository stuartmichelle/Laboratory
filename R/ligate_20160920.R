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

# calculate volume in to 3 digits
not_ligated$vol_in <- as.numeric(formatC(not_ligated$DNA/not_ligated$quant, digits = 3))

# check the max and min to make sure the volumes are between 0.5 and 22.2
max(not_ligated$vol_in) # 21.1
min(not_ligated$vol_in) # 1.5

# add water
not_ligated$water <- as.numeric(formatC((22.2 - not_ligated$vol_in), digits = 3))



##############################################################################



need$ng_in <- (need$quant)*30

# cut down to one plate size
need <- need[1:96, ]

# add digest numbers
n <- data.frame(labor %>% tbl("digest") %>% summarize(n()))
x <- n[1,]
need$digest_ID <- 1:96
need$digest_ID <- paste("D", (need$digest_ID + x), sep = "")


# create a platemap
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, need[,4])
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# create a source map
sourcelist <- cbind(plate, need[1])
names(sourcelist) <- c("Row", "Col", "ID")
sourcelist$ID <- as.character(sourcelist$ID)
sourcemap <- as.matrix(reshape2::acast(sourcelist,sourcelist[,1] ~ sourcelist[,2]))
write.csv(sourcemap, file = paste("data/", Sys.Date(), "map.csv", sep = ""))

##################################################################################
# After digest is complete, add additional info (enzymes, final vol, quant, DNA)

# create an import file for database
write.csv(need, file = paste("data/", Sys.Date(), "digestforimport.csv", sep = ""))
