# this is a script to make a plate from the locations in the database

mkplatedb <- function(){
  plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))
  
  
  plate1 <- cbind(plate,ID)
  names(plate1) <- c("Row", "Col", "ID")
  first <- plate1$ID[1]
  last <- plate1$ID[nrow(plate1)]
  return(plate1)
}
