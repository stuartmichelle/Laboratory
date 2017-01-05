# a function to connect to the laboratory database

conlabor <- function(){
  suppressMessages(library(dplyr))
  labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)
  return(labor)
}
