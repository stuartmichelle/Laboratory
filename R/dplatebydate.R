# Add Source locations, starting with the first plate ---------------------

dplatebydate <- function(x){
  S1_first <- x$digest_id[floor(which(x$digest_id == biomek_sample$digest_id[1])/96)*96 + 1]
  filelist <- sort(list.files(path="data/", pattern = S1_first), decreasing=FALSE)
  pick <- paste("data/", filelist[1], sep = "")
  S1 <<- read.csv(pick[1], row.names = 1)
  biomek_sample <<- merge(biomek_sample, S1, by.x = "digest_id", by.y = "ID", all.x = T)
  biomek_sample$sourcewell <<- paste(biomek_sample$Row, biomek_sample$Col, sep = "")
  biomek_sample$Row <<- NULL
  biomek_sample$Col <<- NULL
  S1 <<- biomek_sample[which(biomek_sample$sourcewell != "NANA"), ]
  biomek_sample <<- biomek_sample[which(biomek_sample$sourcewell == "NANA"), ]
  biomek_sample <<- biomek_sample[order(biomek_sample$digest_id), ]
}
