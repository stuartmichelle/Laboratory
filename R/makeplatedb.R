# this is a script to make a plate from the locations in the database

mkplatedb <- function(x){
  # pull plate data from db
  source("R/conlabor.R")
  labor <- conlabor()
  if (substr(x, 1,1) == "L"){
    plate <- labor %>% tbl("ligation") %>% filter(plate == x) %>% select(ligation_id, well) %>% collect()
  }
  if (substr(x, 1,1) == "D"){
    plate <- labor %>% tbl("digest") %>% filter(plate == x) %>% select(digest_id, well) %>% collect()
  }
  if (substr(x, 1,1) == "E"){
    plate <- labor %>% tbl("extraction") %>% filter(plate == x) %>% select(extraction_id, well) %>% collect()
  }
  plate$row <- substr(plate$well, 1, 1)
  plate$col <- substr(plate$well, 2, 3)
  plate$well <- NULL
  names(plate) <- c("id, row, col")
  return(plate)
}
