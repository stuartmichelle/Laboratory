# This is a script to find Ligations that need to be re-done due to lab error


# Connect to databases
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)
leyte <- src_mysql(dbname = "Leyte", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# get the list of ligations that need to be regenotyped
ligs <- leyte %>% tbl("known_issues") %>% select(Issue, contains("regenotype"))

# make sure they haven't already been regenotyped and aren't on the list of good matches
