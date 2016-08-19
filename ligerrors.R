# This is a script to find Ligations that need to be re-done due to lab error


# Connect to databases
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)
leyte <- src_mysql(dbname = "Leyte", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# get the list of ligations that need to be regenotyped
ligs <- data.frame(leyte %>% tbl("known_issues") %>% select(Ligation_ID, Issue, contains("regenotype")))

# make sure they aren't on the list of good matches
matches <- read.csv("~/Documents/Philippines/Genetics/2016-08-19matches.csv")

bingo <- data.frame(Ligation_ID = character(0), Issue = character(0))

for (i in 1:nrow(ligs)){
bingo$Ligation_ID[i] <- ligs$Ligation_ID[which(ligs$Ligation_ID[i] == matches$First.ID)]
}

for (i in 1:nrow(ligs)){
  bingo$Ligation_ID[i] <- ligs$Ligation_ID[which(ligs$Ligation_ID[i] == matches$Second.ID)]
}

# Find the extraction IDs of the samples to be regenotyped

