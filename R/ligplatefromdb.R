# a script to make platemaps from ligation data based on barcode id

# make a list of columns and rows (the locations for the platemap only)
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))

# import lab ids for the plate
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

# choose a pool combination to create a map for
pool1 <- "P020"
pool2 <- "P021"

suppressWarnings(pool <- labor %>% tbl("ligation") %>% select(pool, barcode_num,digest_id,ligation_id) %>% filter(pool == pool1 | pool == pool2) %>% arrange(pool, barcode_num) %>% collect())

plate1 <- cbind(plate, pool$ligation_id)
names(plate1) <- c("Row", "Col", "ligation_id")
first <- plate1$ligation_id[1]
last <- plate1$ligation_id[nrow(plate1)]
write.csv(plate1, file = paste("data/", first, "-", last, "list.csv", sep = ""))
plate1$ligation_id <- as.character(plate1$ligation_id)
platemap <- as.matrix(reshape2::acast(plate1,plate1[,1] ~ plate1[,2]))
write.csv(platemap, file = paste("data/", first, "-",last, "map.csv", sep = ""))

# view sources
source1 <- cbind(plate, pool$digest_id)
names(source1) <- c("Row", "Col", "digest_id")
write.csv(source1, file = paste("data/source_", first, "-", last, "list.csv", sep = ""))
source1$digest_id <- as.character(source1$digest_id)
platemap <- as.matrix(reshape2::acast(source1,source1[,1] ~ source1[,2]))
write.csv(platemap, file = paste("data/source_", first, "-",last, "map.csv", sep = ""))

