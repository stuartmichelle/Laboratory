# Add Source locations, starting with the first plate ---------------------

dplatebydate <- function(x){
  S1_first <- x$digest_id[floor(which(x$digest_id == biomek_sample$digest_id[1])/96)*96 + 1]
  filelist <- sort(list.files(path="data/", pattern = S1_first), decreasing=FALSE)
  pick <- paste("data/", filelist[1], sep = "")
  S1 <<- read.csv(pick[1], row.names = 1)
  dest <<- merge(dest, S1, by.x = "extraction_ID", by.y = "ID", all.x = T)
  dest$sourcewell <<- paste(dest$Row, dest$Col, sep = "")
  dest$Row <<- NULL
  dest$Col <<- NULL
  S1 <<- dest[which(dest$sourcewell != "NANA"), ]
  dest <<- dest[which(dest$sourcewell == "NANA"), ]
  dest <<- dest[order(dest$extraction_ID), ]
}
