# a script for preparing PCR data for database

suppressMessages(library(dplyr))

# use the pool table from the ligation script to move forward
pcr <- pool

# or, if pool table is unavailable, make a table of pools to be used
# pcr <- c("P069", "P070", "P071", "P072")

### for illumina adapters use combinations: 1,8,10,11, or 6,12,*, *.  More than 4 pools can receive any other barcode in addition to 1, 8, 10, 11.


pcr$pcr_id <- paste("P", substr(pcr$pool_id, 2,4), sep = "")
pcr$date <- as.Date("2016-10-03")
pcr$rxns <- 4
pcr$index[1] <- 1
pcr$index[2] <- 8 
pcr$index[3] <- 10
pcr$index[4] <- 11
pcr$vol_rxns <- 20
pcr$bp <- 430

# input qubit results of PCR quantification after cleanup
pcr$quant <-

# calculate the nmol/L
pcr <- pcr %>% mutate(nmol_L = pcr$quant/(660*pcr$bp)*1000000)

# calculate volume of product needed to make 30µL of 10nM solution
pcr <- pcr %>% mutate(product = 30*10/pcr$nmol_L)

# calculate the amount of water to add 
pcr <- pcr %>% mutate(water = 30-pcr$product)

# add seq number
pcr$SEQ <- "SEQ17"
