devtools::load_all()

# For each source, retrieve the data and save them
dp_snsf_works <- get_snsf_work_dp(2020:2023)
usethis::use_data(dp_snsf_works, overwrite = TRUE)
oax_snsf_works <- get_snsf_work_oax(2020:2023)
usethis::use_data(oax_snsf_works, overwrite = TRUE)
dim_snsf_works <- get_snsf_work_dim(2020:2023)
usethis::use_data(dim_snsf_works, overwrite = TRUE)
cr_snsf_works <- get_snsf_work_cr(2020:2023)
usethis::use_data(cr_snsf_works, overwrite = TRUE)

# Save the date when the data were created
utils <- read_lines("R/utils.R")
utils[grepl("^snsf_oa_.+_created", utils)] <- paste0(
  "snsf_oa_ror_zurich_26_data_created <- \"", Sys.Date(), "\""
)
writeLines(utils, "R/utils.R")
