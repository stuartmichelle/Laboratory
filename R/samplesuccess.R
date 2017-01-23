# a script that, for each sample id, determines if the sample has been successfully genotyped and if it is a recapture

# start with field data source of sample_ids
source("../../Philippines/code/conleyte.R")
leyte <- conleyte()

fish <- leyte %>% tbl("clownfish") %>% select(sample_id, capid, recap, tagid) %>% filter(!is.na(sample_id)) %>%collect() #2924 fish

# connect these fish to labwork
# source("R/conlabor.R")
source("R/findlabwork.R")
# labor <- conlabor()
reads <- read.csv("../../Philippines/Genetics/data/APCL_read_data.csv")
labwork <- data.frame(sample_id=character(), extraction_id=character(), digest_id=character(), ligation_id=character(), pool=character(), SEQ=character(), reads=character(), stringsAsFactors = F)


# i <- 1
for (i in 1:nrow(fish)){
  X <- findlab(fish$sample_id[i])
  if(is.na(X$ligation_id)){
    X[i, ] <- NA
    X$reads <- NA
    labwork <- rbind(labwork, X)
  }else{
    X$reads <- reads$total_reads[which(reads$ligation_id == X$ligation_id)]
    labwork <- rbind(labwork, X)
  }
}
  
