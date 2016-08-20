# This function finds the platemap worked on for a given lab procedure

findplatelist <- function(original,dest,firstwell,lastwell){
  S1_first <- x[firstwell]
  S1_last <- x[lastwell]
  
  if (y[1] < S1_last){
    filelist <- sort(list.files(path='.', pattern = S1_first), decreasing=FALSE)
    read.csv(filelist[1], row.names = 1)
  }
}
