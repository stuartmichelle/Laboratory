# a script to make platemaps from ligation data based on barcode id
source("R/platefromlist.R")

# import lab ids for the plate
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

# choose a plate of digests to create a plate map for
suppressWarnings(dig <- labor %>% tbl("digest") %>% select(digest_id, extraction_id, well, plate, date) %>% filter(plate == "D1355-D1450") %>% collect())

# split the well out into row and column again
dig$Row <- substr(dig$well, 1, 1)
dig$Col <- substr(dig$well, 2, 3)


plate1 <- dig[ , c("Row", "Col", "digest_id")]
names(plate1) <- c("Row", "Col", "ID")
first <- plate1$ID[1]
last <- plate1$ID[nrow(plate1)]

# for some reason the platemap works from a csv but not from plate1
filename <- paste("data/", first, "-", last, "list.csv", sep = "")
write.csv(plate1, file = filename)

# use Michelle's function to make platemap
platemap(filename)




