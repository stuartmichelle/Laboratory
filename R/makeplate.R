# this is a script to make a plate from a table containing 3 columns of data and 96 rows 

makeplate <- function(){
  plate1 <- cbind(plate,ID)
  names(plate1) <- c("Row", "Col", "ID")
  first <- plate1$ID[1]
  last <- plate1$ID[nrow(plate1)]
  return(plate1)
}
