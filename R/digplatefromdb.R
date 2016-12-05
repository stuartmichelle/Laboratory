# a script to make platemaps from ligation data based on barcode id

# make a list of columns and rows (the locations for the platemap only)
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))

# import lab ids for the plate
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

# choose a plate of digests to create a plate map for
suppressWarnings(dig <- labor %>% tbl("digest") %>% select(digest_id, extraction_id, well, plate, date) %>% filter(plate == "D0940-D1035") %>% collect())

# split the well out into row and column again
dig$Row <- substr(dig$well, 1, 1)
dig$Col <- substr(dig$well, 2, 3)

# cut down to the number of rows needed
i <- nrow(dig)
if(i < 96){
  plate <- plate[1:i,]
}

plate1 <- cbind(plate, dig$digest_id)
names(plate1) <- c("Row", "Col", "digest_id")
first <- plate1$digest_id[1]
last <- plate1$digest_id[nrow(plate1)]
write.csv(plate1, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate1$digest_id <- as.character(plate1$digest_id)
platemap <- as.matrix(reshape2::acast(plate1,plate1[,1] ~ plate1[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# view sources
source1 <- cbind(plate, pool$digest_id)
names(source1) <- c("Row", "Col", "digest_id")
write.csv(source1, file = paste("data/source_", first, "-", last, "list.csv", sep = ""))
source1$digest_id <- as.character(source1$digest_id)
platemap <- as.matrix(reshape2::acast(source1,source1[,1] ~ source1[,2]))
write.csv(platemap, file = paste("data/source_", first, "-",last, "map.csv", sep = ""))

