# plan a digest run

# determine which, if any, samples from the extract plate cannot be digested (DNA > 5ug)

suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# pull extract IDs from digest table
digextr <- data.frame(labor %>% tbl("digest") %>% select(extraction_ID, digest_ID))

# pull extract IDs from extraction table
extr <- data.frame(labor %>% tbl("extraction") %>% select (extraction_ID, date, DNA_ug))

# merge so that all extraction IDs that have not been digested have an NA for digest ID
done <- full_join(extr, digextr, by = "extraction_ID")

# create a table for all extracts that do not have a digest ID
need <- done[is.na(done$digest_ID),]

# eliminate samples with less than 5ug of DNA
need <- need[which(need$DNA_ug > 5), ]
