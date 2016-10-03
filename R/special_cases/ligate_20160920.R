# plan a ligation run

### IN THIS SCRIPT, ALL OF THE WRITE.CSV LINES HAVE BEEN COMMENTED OUT BECAUSE THESE SAMPLES HAVE ALREADY BEEN WRITTEN TO FILE, UNCOMMENT FOR NEW SAMPLES ###

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
not_ligated <- not_ligated[ , c(2, 5, 6, 10, 11, 12)]

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
source("R/dplatebydate.R")

# make an extract empty data frame to bind new rows to
samples <- data.frame(digest_ID = character(0), dnavol = character(0), watervol = character(0), ligation_ID = character(0), destloc = character(0), welldest = character(0), wellsource = character(0), sourceloc= character(0))

numplate <- 9 # number of expected source plates
for (i in 1:numplate){
    E1 <- labor %>% tbl("digest") %>% select(digest_id, date) %>% filter(date == biomek_sample$date[1])
    E1 <- collect(E1)
    dplatebydate(E1)
    S1$sourceloc <- i
    samples <- rbind(samples, S1)
}

rm(E1, n, S1, first, last, i, numplate, x)
# 36 warnings, all decimals imported as numeric

# assign run numbers
samples$run <- NA
samples$run[samples$sourceloc == 1] <- 1
samples$run[samples$sourceloc == 2] <- 1
samples$run[samples$sourceloc == 3] <- 1
samples$run[samples$sourceloc == 4] <- 1
samples$run[samples$sourceloc == 5] <- 2
samples$run[samples$sourceloc == 6] <- 2
samples$run[samples$sourceloc == 7] <- 2
samples$run[samples$sourceloc == 8] <- 2
samples$run[samples$sourceloc == 9] <- 2

# assign source locations
samples$sourceloc[samples$sourceloc == 1 | samples$sourceloc == 5 ] <- "P10"
samples$sourceloc[samples$sourceloc == 2 | samples$sourceloc == 6 ] <- "P5"
samples$sourceloc[samples$sourceloc == 3 | samples$sourceloc == 7 ] <- "P6"
samples$sourceloc[samples$sourceloc == 4 | samples$sourceloc == 8 ] <- "P7"
samples$sourceloc[samples$sourceloc == 9] <- "P9"

# split table into 2 runs plus a water run
run1 <- biomek_water
run2 <- samples[samples$run == 1, ]
run3 <- samples[samples$run == 2, ]

# write.csv(run1, file = paste(Sys.Date(), "biomek_water.csv", sep = ""))
# write.csv(run2, file = paste(Sys.Date(), "biomek_samples_run1.csv", sep = ""))
# write.csv(run3, file = paste(Sys.Date(), "biomek_samples_run2.csv", sep = ""))

# split table into 2 plates
plate1 <- not_ligated[1:96, ]
plate2 <- not_ligated[97:192, ]

# create a platemap for first plate
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, plate1[,2])
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
# write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
# write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# create a platemap for second plate
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
platelist <- cbind(plate, plate2[,2])
names(platelist) <- c("Row", "Col", "ID")
first <- platelist$ID[1]
last <- platelist$ID[nrow(platelist)]
# write.csv(platelist, file = paste("data/", first, "-", last, "list.csv", sep = ""))
platelist$ID <- as.character(platelist$ID)
platemap <- as.matrix(reshape2::acast(platelist,platelist[,1] ~ platelist[,2]))
# write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# create a source map for first plate
sourcelist <- cbind(plate, plate1[ , 1])
names(sourcelist) <- c("Row", "Col", "ID")
sourcelist$ID <- as.character(sourcelist$ID)
sourcemap <- as.matrix(reshape2::acast(sourcelist,sourcelist[,1] ~ sourcelist[,2]))
# write.csv(sourcemap, file = paste("data/", Sys.Date(), "map1.csv", sep = ""))

# create a source map for second plate
sourcelist <- cbind(plate, plate2[ , 1])
names(sourcelist) <- c("Row", "Col", "ID")
sourcelist$ID <- as.character(sourcelist$ID)
sourcemap <- as.matrix(reshape2::acast(sourcelist,sourcelist[,1] ~ sourcelist[,2]))
# write.csv(sourcemap, file = paste("data/", Sys.Date(), "map2.csv", sep = ""))

# create an import file for database
biomek_sample <- samples[ , c(2, 1, 4, 5, 6)]

# add date
biomek_sample$date <- as.Date("2016-09-21")

# add barcode
biomek_sample <- biomek_sample[order(biomek_sample$ligation_id), ]
biomek_sample$barcode <- 1:48

# add pool
n <- data.frame(labor %>% tbl("pool") %>% summarize(n()))
x <- n[1,]
pool_id <- 1:4
pool_id <- paste("P", formatC(pool_id + x, width = 3, format = "d", flag = "0"), sep = "")
biomek_sample$pool[1:48] <- pool_id[1]
biomek_sample$pool[49:96] <- pool_id[2]
biomek_sample$pool[97:144] <- pool_id[3]
biomek_sample$pool[145:192] <- pool_id[4]

# create csv to import to database
# write.csv(biomek_sample, file = paste("data/", Sys.Date(), "ligateforimport.csv", sep = ""))

# create a pool csv to import to database
pool <- as.data.frame((unique(biomek_sample$pool)))
pool$date <- as.Date("2016-09-22")
names(pool) <- c("pool_id", "date")
pool$pool_id <- paste("Pool", substr(pool$pool_id,2,4), sep = "")
pool$buffer <- 30
pool$size <- 375
pool$vol_from_pippin <- 40

# write.csv(pool, file = paste("data/", Sys.Date(), "poolforimport.csv", sep = ""))
