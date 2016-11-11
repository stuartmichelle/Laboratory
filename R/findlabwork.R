# This script is intended to take a given sample ID and find all of the labwork done to that sample

# Connect to database
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", host = "amphiprion.deenr.rutgers.edu", user = "michelles", password = "larvae168", port = 3306, create = F)

# enter sample you are looking for
sample <- "APCL13_230"

# Find extractions
work <- labor %>% tbl("extraction") %>% filter(sample_id == sample) %>% select(sample_id, extraction_id) %>% collect()

# Add digests
dig <- labor %>% tbl("digest") %>% filter(extraction_id == work$extraction_id) %>% select(extraction_id, digest_id) %>% collect()
work <- left_join(work, dig, by = "extraction_id")

# Add ligations
if (nrow(work) > 1){
  suppressWarnings(lig <- labor %>% tbl("ligation") %>% filter(digest_id %in% work$digest_id) %>% select(ligation_id, digest_id, pool) %>% collect())
}else{
  suppressWarnings(lig <- labor %>% tbl("ligation") %>% filter(digest_id == work$digest_id) %>% select(ligation_id, digest_id, pool) %>% collect())
}
work <- left_join(work, lig, by = "digest_id")
colnames(work) <- c("sample_id", "extraction_id", "digest_id", "ligation_id", "pcr_id")

# Add SEQ
if (nrow(work) > 1){
  suppressWarnings(seq <- labor %>% tbl("pcr") %>% filter(pcr_id %in% work$pcr_id) %>% select(pcr_id, SEQ) %>% collect())
}else{
  suppressWarnings(seq <- labor %>% tbl("pcr") %>% filter(pcr_id == work$pcr_id) %>% select(pcr_id, SEQ) %>% collect())
}
work <- left_join(work, seq, by = "pcr_id")
