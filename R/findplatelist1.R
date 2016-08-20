# This function finds the platemap for the first 96 samples worked on for a given lab procedure on a given day

findplatelist1 <- function(x,y){
  S1_first <- x[1]
  S1_last <- x[96]
  
  if (y[1] < S1_last){
    filelist <- sort(list.files(path='.', pattern = S1_first), decreasing=FALSE)
    read.csv(filelist[1], row.names = 1)
  }
}
