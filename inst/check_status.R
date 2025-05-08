#!/usr/bin/env Rscript

check_rds <- here::here("slide_check_cache.rds")

check_tbl <- readRDS(check_rds)
check_results <- check_tbl[["compile_check"]]

# All TRUE -> all good, so if not all TRUE then exist status should translate to 1
res <- !all(check_results)

quit(save = "no", status = as.integer(res))
