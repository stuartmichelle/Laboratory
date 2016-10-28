# read in plate reader data and add to digest table
# this code is in progress!!!


# read in plate reader data
platefile = "data/20160919_plate1.txt"
namefile = "data/D3247-D3339list.csv"
colsinplate = 2:12 # is this a full plate?
# colsinplate = 1 # or is this just the first column of the plate?

strs <- readLines(platefile, skipNul = T)
linestoskip = (which(strs == "Group: Unk_Dilution"))

dat <- read.table(text = strs,  skip = linestoskip, sep = "\t", stringsAsFactors = F, fill = T, col.names = c("Sample", "Wells", "Value", "R", "Result", "MeanResult", "SD", "CV", "Dilution", "AdjResult"), row.names = 1)
dat <- dat[13:(which(dat$Sample == "Group Column")-1), ]

# read in names for the samples
names <- read.csv(namefile, row.names = 1)

names$Wells <- paste(names$Row, names$Col, sep = "")

quant <- dplyr::left_join(dat, names, by = "Wells")

quant <- quant[ , c("ID", "AdjResult")]
colnames(quant) <- c("digest_id", "quant")

# Retrieve the digest data from the database using dplyr
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# pull in all of the digest data
suppressWarnings(digest <- labor %>% tbl("digest") %>% collect())

# append to the data in the database using RMySQL
library(RMySQL)
labors <- dbConnect(MySQL(), host="amphiprion.deenr.rutgers.edu", user="michelles", password="larvae168", dbname="Laboratory", port=3306)

# Send data to database
dbWriteTable(labor,"digest",data.frame(quant), row.names = FALSE, append = TRUE)

dbDisconnect(leyte)
rm(leyte)

