# This script is intended to take a given sample ID and find all of the labwork done to that sample

# Connect to database
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

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

# Add SEQ
if (nrow(work) > 1){
  suppressWarnings(seq <- labor %>% tbl("pcr") %>% filter(pcr_id %in% work$pool) %>% select(pcr_id, SEQ) %>% collect())
}else{
  suppressWarnings(seq <- labor %>% tbl("pcr") %>% filter(pcr_id == work$pool) %>% select(pcr_id, SEQ) %>% collect())
}
work <- left_join(work, seq, by = c("pool" = "pcr_id"))
