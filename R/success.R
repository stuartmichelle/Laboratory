# did labwork result in successful sequencing?
source("R/findlabwork.R")
source("../../Philippines/Genetics/code/readGenepop_space.R")

Y <- "APCL13_509"

X <- findlab(Y)

# find number of reads
reads <- read.csv("../../Philippines/Genetics/data/APCL_read_data.csv")

print(reads$total_reads[which(reads$ligation_id == X$ligation_id)])

# is it in the genepop that came out of dDocent
genfile <- "../../Philippines/Genetics/data/809_seq17_03.gen"
genedf <- readGenepop(genfile)
### WAIT ###
A <- genedf$names[which(substr(genedf$names, 11, 15) == X$ligation_id)]
if (substr(A, 1, 1) == "A"){
  B <- "successfully completed dDocent"
}else{
  B <- "did not successfully complete dDocent"
}

# did it match to any recaptures?
match <- read.csv("../../Philippines/Genetics/data/809_seq17-03_ID.csv")
D <- NA
C <- match$First.ID[which(match$First.ID == X$ligation_id | match$Second.ID == X$ligation_id)]
if (substr(C, 1, 1) == "L"){
  D <- paste("matches ", match$First.ID, " to ", match$Second.ID, sep = "")
}else{
  D <- "does not match to other samples"
}

# summary text
paste(Y, " has ", print(reads$total_reads[which(reads$ligation_id == X$ligation_id)]), " reads, ", B, " and ", sep = "")
# does not match to any other samples
