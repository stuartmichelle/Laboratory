# This script is intended to take a given lab ID and find the sample ID

# Connect to database
suppressMessages(library(dplyr))
labor <- src_mysql(dbname = "Laboratory", default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)

# enter id of the labwork - "L2345", "SEQ17", "P037"
sample <- "D2345"

# Find the sample_ID
if (substr(sample, 1,1) == "L"){
  suppressWarnings(lig <- labor %>% tbl("ligation") %>% filter(ligation_id == sample) %>% select(ligation_id, digest_id) %>% collect())
  suppressWarnings(dig <- labor %>% tbl("digest") %>% filter(digest_id == lig$digest_id) %>% select(extraction_id, digest_id) %>% collect)
  lig <- left_join(lig, dig, by = "digest_id")
  suppressWarnings(extr <- labor %>% tbl("extraction") %>% filter(extraction_id == dig$extraction_id) %>% select(extraction_id, sample_id) %>% collect())
  lig <- left_join(lig, extr, by = "extraction_id")
  rm(dig, extr)
}

if (substr(sample, 1,1) == "D"){
  suppressWarnings(dig <- labor %>% tbl("digest") %>% filter(digest_id == sample) %>% select(extraction_id, digest_id) %>% collect())
  suppressWarnings(extr <- labor %>% tbl("extraction") %>% filter(extraction_id == dig$extraction_id) %>% select(extraction_id, sample_id) %>% collect())
  dig <- left_join(dig, extr, by = "extraction_id")
  rm(extr)
}

if (substr(sample, 1,1) == "E"){
  suppressWarnings(extr <- labor %>% tbl("extraction") %>% filter(extraction_id == sample) %>% select(extraction_id, sample_id) %>% collect())
}

if (substr(sample, 1,1) == "S"){
  suppressWarnings(seq <- labor %>% tbl("pcr") %>% filter(SEQ == sample) %>% select(pcr_id, SEQ) %>% collect())
  suppressWarnings(lig <- labor %>% tbl("ligation") %>% filter(pool %in% seq$pcr_id) %>% select(ligation_id, digest_id, pool) %>% collect())  # this line will return an error if there is only one pool in the seq, change %in% to ==
  seq <- left_join(seq, lig, by = c("pcr_id" = "pool"))
  suppressWarnings(dig <- labor %>% tbl("digest") %>% filter(digest_id %in% seq$digest_id) %>% select(extraction_id, digest_id) %>% collect)
  seq <- left_join(seq, dig, by = "digest_id")
  suppressWarnings(extr <- labor %>% tbl("extraction") %>% filter(extraction_id %in% seq$extraction_id) %>% select(extraction_id, sample_id) %>% collect())
  seq <- left_join(seq, extr, by = "extraction_id")
  rm(dig, extr, lig)
}

if (substr(sample, 1,1) == "P"){
    suppressWarnings(lig <- labor %>% tbl("ligation") %>% filter(pool == sample) %>% select(pool, ligation_id, digest_id) %>% collect())
    suppressWarnings(dig <- labor %>% tbl("digest") %>% filter(digest_id %in% lig$digest_id) %>% select(extraction_id, digest_id) %>% collect())
    lig <- left_join(lig, dig, by = "digest_id")
    suppressWarnings(extr <- labor %>% tbl("extraction") %>% filter(extraction_id %in% dig$extraction_id) %>% select(extraction_id, sample_id) %>% collect())
    lig <- left_join(lig, extr, by = "extraction_id")
    rm(dig, extr)
  }

