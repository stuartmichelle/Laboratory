# This is a script to find Ligations that need to be re-done due to lab error


# Connect to databases
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)
leyte <- src_mysql(dbname = "Leyte", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# get the list of ligations that need to be regenotyped
ligs <- data.frame(leyte %>% tbl("known_issues"))
ligs <- filter(ligs, grepl('regenotype', Issue))



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
c1 <- labor %>% tbl("extraction") %>% select(extraction_ID, sample_ID, date)
c2 <- labor %>% tbl("digest") %>% select(digest_ID, extraction_ID)
c3 <- left_join(c2, c1, by = "extraction_ID")
c4 <- labor %>% tbl("ligation") %>% select(ligation_ID, digest_ID)
c5 <- left_join(c4, c3, by = "digest_ID")
ligs <- left_join(ligs, c5, by = c("Ligation_ID" = "ligation_ID"), copy = T )

# make a platemap_list of the destination digests 
plate <- data.frame( Row = rep(LETTERS[1:8], 12), Col = unlist(lapply(1:12, rep, 8)))

# cut down to the number of rows needed
i <- nrow(ligs)
if(i < 96){
  plate <- plate[1:i,]
}

dest <- cbind(plate, ligs[ , c("Ligation_ID","extraction_ID", "date")])
dest$destwell <- paste(dest$Row, dest$Col, sep = "")
# clean up 
dest$Row <- NULL
dest$Col <- NULL
dest$Ligation_ID <- NULL
dest$destloc <- "P12"

# add source locations

# extracts from the first plate
E1 <- data.frame(labor %>% tbl("extraction") %>% filter(date == dest$date[1]), stringsAsFactors = F)

source("R/findplatelist1.R")
S1 <- findplatelist1(E1$extraction_ID, dest$extraction_ID)

# the specific digest plate
names(S1) <- c("Row", "Col", "ID")

dest <- merge(dest, S1, by.x = "extraction_ID", by.y = "ID", all.x = T)
dest$sourcewell <- paste(dest$Row, dest$Col, sep = "")

# clean up
dest$Row <- NULL
dest$Col <- NULL

# split out digests by plate

S1 <- dest[which(dest$sourcewell != "NANA"), ]
S1$sourceloc <- "P13"

dest <- dest[which(dest$sourcewell == "NANA"), ]

# extracts from the next plate
E1 <- data.frame(labor %>% tbl("extraction") %>% filter(date == dest$date[1]), stringsAsFactors = F)

S2_first <- E1$extraction_ID[1]
S2_last <- E1$extraction_ID[96]

if (dest$extraction_ID[1] < S2_last){
  filelist <- sort(list.files(path='.', pattern = S2_first), decreasing=FALSE)
  S2 <- read.csv(filelist[1], row.names = 1)
}else{
  S2_first <- E1$extraction_ID[97]
  S2_last <- E1$extraction_ID[192]
  if (dest$extraction_ID[1] < S2_last){
    filelist <- sort(list.files(path='.', pattern = S2_first), decreasing=FALSE)
    S2 <- read.csv(filelist[1], row.names = 1)
  }
}

# the specific digest plate
names(S2) <- c("Row", "Col", "ID")

dest <- merge(dest, S2, by.x = "extraction_ID", by.y = "ID", all.x = T)
dest$sourcewell <- paste(dest$Row, dest$Col, sep = "")

# clean up
dest$Row <- NULL
dest$Col <- NULL

# split out digests by plate

S2 <- dest[which(dest$sourcewell != "NANA"), ]
S2$sourceloc <- "P8"

dest <- dest[which(dest$sourcewell == "NANA"), ]

# extracts from the next plate
E1 <- data.frame(labor %>% tbl("extraction") %>% filter(date == dest$date[1]), stringsAsFactors = F)



S3_first <- E1$extraction_ID[1]
S3_last <- E1$extraction_ID[96]

if (dest$extraction_ID[1] < S3_last){
  filelist <- sort(list.files(path='.', pattern = S3_first), decreasing=FALSE)
  S3 <- read.csv(filelist[1], row.names = 1)
}else{
  S3_first <- E1$extraction_ID[97]
  S3_last <- E1$extraction_ID[192]
  if (dest$extraction_ID[1] < S3_last){
    filelist <- sort(list.files(path='.', pattern = S3_first), decreasing=FALSE)
    S3 <- read.csv(filelist[1], row.names = 1)
  }else{
    S3_first <- E1$extraction_ID[193]
    S3_last <- E1$extraction_ID[288]
    if (dest$extraction_ID[1] < S3_last){
      filelist <- sort(list.files(path='.', pattern = S3_first), decreasing=FALSE)
      S3 <- read.csv(filelist[1], row.names = 1)
  }
}

# the specific digest plate
names(S3) <- c("Row", "Col", "ID")

dest <- merge(dest, S3, by.x = "extraction_ID", by.y = "ID", all.x = T)
dest$sourcewell <- paste(dest$Row, dest$Col, sep = "")

# clean up
dest$Row <- NULL
dest$Col <- NULL

# split out digests by plate

S3 <- dest[which(dest$sourcewell != "NANA"), ]
S3$sourceloc <- "P9"

dest <- dest[which(dest$sourcewell == "NANA"), ]

# extracts from the next plate
E1 <- data.frame(labor %>% tbl("extraction") %>% filter(date == dest$date[1]), stringsAsFactors = F)

S4_first <- E1$extraction_ID[1]
S4_last <- E1$extraction_ID[96]

if (dest$extraction_ID[1] < S4_last){
  filelist <- sort(list.files(path='.', pattern = S4_first), decreasing=FALSE)
  S4 <- read.csv(filelist[1], row.names = 1)
}else{
  S4_first <- E1$extraction_ID[97]
  S4_last <- E1$extraction_ID[192]
  if (dest$extraction_ID[1] < S4_last){
    filelist <- sort(list.files(path='.', pattern = S4_first), decreasing=FALSE)
    S4 <- read.csv(filelist[1], row.names = 1)
  }else{
    S4_first <- E1$extraction_ID[193]
    S4_last <- E1$extraction_ID[288]
    if (dest$extraction_ID[1] < S4_last){
      filelist <- sort(list.files(path='.', pattern = S4_first), decreasing=FALSE)
      S4 <- read.csv(filelist[1], row.names = 1)
    }else{
      S4_first <- E1$extraction_ID[289]
      S4_last <- E1$extraction_ID[384]
      if (dest$extraction_ID[1] < S4_last){
        filelist <- sort(list.files(path='.', pattern = S4_first), decreasing=FALSE)
        S4 <- read.csv(filelist[1], row.names = 1)
    }
  }
}
  # the specific digest plate
  names(S4) <- c("Row", "Col", "ID")
  
  dest <- merge(dest, S4, by.x = "extraction_ID", by.y = "ID", all.x = T)
  dest$sourcewell <- paste(dest$Row, dest$Col, sep = "")
  
  # clean up
  dest$Row <- NULL
  dest$Col <- NULL
  
  # split out digests by plate
  
  S4 <- dest[which(dest$sourcewell != "NANA"), ]
  S4$sourceloc <- "P10"
  
  dest <- dest[which(dest$sourcewell == "NANA"), ]
  
  # extracts from the next plate
  E1 <- data.frame(labor %>% tbl("extraction") %>% filter(date == dest$date[1]), stringsAsFactors = F)
  
  S5_first <- E1$extraction_ID[1]
  S5_last <- E1$extraction_ID[96]
  
  if (dest$extraction_ID[1] < S5_last){
    filelist <- sort(list.files(path='.', pattern = S5_first), decreasing=FALSE)
    S5 <- read.csv(filelist[1], row.names = 1)
  }else{
    S5_first <- E1$extraction_ID[97]
    S5_last <- E1$extraction_ID[192]
    if (dest$extraction_ID[1] < S5_last){
      filelist <- sort(list.files(path='.', pattern = S5_first), decreasing=FALSE)
      S5 <- read.csv(filelist[1], row.names = 1)
    }else{
      S5_first <- E1$extraction_ID[193]
      S5_last <- E1$extraction_ID[288]
      if (dest$extraction_ID[1] < S5_last){
        filelist <- sort(list.files(path='.', pattern = S5_first), decreasing=FALSE)
        S5 <- read.csv(filelist[1], row.names = 1)
      }else{
        S5_first <- E1$extraction_ID[289]
        S5_last <- E1$extraction_ID[384]
        if (dest$extraction_ID[1] < S5_last){
          filelist <- sort(list.files(path='.', pattern = S5_first), decreasing=FALSE)
          S5 <- read.csv(filelist[1], row.names = 1)
        }
      }
    }
  }
  # the specific digest plate
    names(S5) <- c("Row", "Col", "ID")
    
    dest <- merge(dest, S5, by.x = "extraction_ID", by.y = "ID", all.x = T)
    dest$sourcewell <- paste(dest$Row, dest$Col, sep = "")
    
    # clean up
    dest$Row <- NULL
    dest$Col <- NULL
    
    # split out digests by plate
    
    S5 <- dest[which(dest$sourcewell != "NANA"), ]
    S5$sourceloc <- "P5"
    
    dest <- dest[which(dest$sourcewell == "NANA"), ]
    
    
    
# extracts from the next plate
E1 <- data.frame(labor %>% tbl("extraction") %>% filter(date == dest$date[1]), stringsAsFactors = F)

    
S6_first <- E1$extraction_ID[1]
S6_last <- E1$extraction_ID[96]
    
if (dest$extraction_ID[1] < S6_last){
  filelist <- sort(list.files(path='.', pattern = S6_first), decreasing=FALSE)
  S6 <- read.csv(filelist[1], row.names = 1)
  }else{
    S6_first <- E1$extraction_ID[97]
    S6_last <- E1$extraction_ID[192]
    if (dest$extraction_ID[1] < S6_last){
      filelist <- sort(list.files(path='.', pattern = S6_first), decreasing=FALSE)
      S6 <- read.csv(filelist[1], row.names = 1)
    }else{
      S6_first <- E1$extraction_ID[193]
      S6_last <- E1$extraction_ID[288]
      if (dest$extraction_ID[1] < S6_last){
        filelist <- sort(list.files(path='.', pattern = S6_first), decreasing=FALSE)
        S6 <- read.csv(filelist[1], row.names = 1)
      }else{
        S6_first <- E1$extraction_ID[289]
        S6_last <- E1$extraction_ID[384]
        if (dest$extraction_ID[1] < S6_last){
          filelist <- sort(list.files(path='.', pattern = S6_first), decreasing=FALSE)
          S6 <- read.csv(filelist[1], row.names = 1)
        }
      }
    }
}
# the specific digest plate
names(S6) <- c("Row", "Col", "ID")
    
dest <- merge(dest, S6, by.x = "extraction_ID", by.y = "ID", all.x = T)
dest$sourcewell <- paste(dest$Row, dest$Col, sep = "")
    
# clean up
dest$Row <- NULL
dest$Col <- NULL
    
# split out digests by plate
    
S6 <- dest[which(dest$sourcewell != "NANA"), ]
S6$sourceloc <- "P6"
    
dest <- dest[which(dest$sourcewell == "NANA"), ]

# extracts from the next plate
E1 <- data.frame(labor %>% tbl("extraction") %>% filter(date == dest$date[1]), stringsAsFactors = F)
nrow(E1)

S7_first <- E1$extraction_ID[1]
S7_last <- E1$extraction_ID[96]

if (dest$extraction_ID[1] < S7_last){
  filelist <- sort(list.files(path='.', pattern = S7_first), decreasing=FALSE)
  S7 <- read.csv(filelist[1], row.names = 1)
}else{
  S7_first <- E1$extraction_ID[97]
  S7_last <- E1$extraction_ID[192]
  if (dest$extraction_ID[1] < S7_last){
    filelist <- sort(list.files(path='.', pattern = S7_first), decreasing=FALSE)
    S7 <- read.csv(filelist[1], row.names = 1)
  }else{
    S7_first <- E1$extraction_ID[193]
    S7_last <- E1$extraction_ID[288]
    if (dest$extraction_ID[1] < S7_last){
      filelist <- sort(list.files(path='.', pattern = S7_first), decreasing=FALSE)
      S7 <- read.csv(filelist[1], row.names = 1)
    }else{
      S7_first <- E1$extraction_ID[289]
      S7_last <- E1$extraction_ID[384]
      if (dest$extraction_ID[1] < S7_last){
        filelist <- sort(list.files(path='.', pattern = S7_first), decreasing=FALSE)
        S7 <- read.csv(filelist[1], row.names = 1)
      }
    }
  }
}

# the specific digest plate
names(S7) <- c("Row", "Col", "ID")

dest <- merge(dest, S7, by.x = "extraction_ID", by.y = "ID", all.x = T)
dest$sourcewell <- paste(dest$Row, dest$Col, sep = "")

# clean up
dest$Row <- NULL
dest$Col <- NULL

# split out digests by plate

S7 <- dest[which(dest$sourcewell != "NANA"), ]
S7$sourceloc <- "P7"

dest <- dest[which(dest$sourcewell == "NANA"), ]
    

############################################################################
# add source positions to each of the source plates
source1$sourceloc <- "P9"
source2$sourceloc <- "P10"
source3$sourceloc <- "P5"

# merge the source files together
ultimate <- rbind(source1, source2, source3)
ultimate$dnavol <- round(ultimate$dnavol, 2)
ultimate$watervol <- round(ultimate$watervol, 2)


# pull out the water information
water <- ultimate
water$wellsource <- "A1"
water$sourceloc <- "P12"

write.csv(ultimate, file = paste(Sys.Date(), "biomek.csv", sep = ""))

write.csv(water, file = paste(Sys.Date(), "water.csv", sep = ""))

penultimate <- rbind(ultimate, water)
penultimate <- penultimate[order(penultimate$digest_ID), ]

write.csv(penultimate, file = paste(Sys.Date(), "combo.csv", sep = ""))

