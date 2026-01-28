#' @noRd
add_db_to_colnames <- function(df, label) {
  df |>
    dplyr::rename_with(
      .cols = !dplyr::matches("doi"),
      \(x) paste0(label, "_", x)
    ) |>
    dplyr::relocate(doi)
}

#' @noRd
snsf_oa_ror_zurich_26_data_created <- "2026-01-20"
