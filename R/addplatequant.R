# read in plate reader data and add to digest table


# read in plate reader data
platefile = "~/Downloads/20160908_plate1.txt"
namefile = ""

strs <- readLines(platefile, skipNul = T)
dat <- read.table(text = strs,  skip = 61, sep = "\t", stringsAsFactors = F, fill = T, col.names = c("Sample", "Wells", "Value", "R", "Result", "MeanResult", "SD", "CV", "Dilution", "AdjResult"))
dat <- dat[13:(which(dat$Sample == "Group Column")-1), ]

# read in 