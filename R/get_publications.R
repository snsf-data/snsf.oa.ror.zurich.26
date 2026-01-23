#' Get SNSF OA monitoring data from Github
#'
#' @param repo The name of the OA monitoring repository.
#' @param file The name of the data file.
#' @param url The url where is stored the raw content of the SNSF Github
#' page (default to "https://raw.githubusercontent.com/snsf-data/").
#' @param vars A vector with the name of the variable to keep from the SNSF Data
#' Portal.
#'
#' @returns A data frame.
#' @export

get_snsf_oa_work <- function(
  repo,
  file,
  url = "https://raw.githubusercontent.com/snsf-data/",
  vars = c("doi", "id", "publication_year", "type")
) {
  dat <- readr::read_csv(file.path(url, repo, "main", "data", file)) |>
    # Filter publications that are books or monograph
    dplyr::mutate(
      oa_status = forcats::fct_relevel(
        dplyr::recode(oa_status, "closed" = "restricted"),
        c("gold", "green", "hybrid", "other OA", "restricted")
      ),
      # SNSF only considers gold, green and hybrid as OA ("other OA" are mainly
      # non-peer-reviewed OA records).
      is_oa = oa_status %in% c("gold", "green", "hybrid"),
      # Unify the reference to the Data Portal in the type
      type = stringr::str_replace(
        type,
        "\\((DP|Data Portal|P3)\\)",
        "(Data Portal)"
      )
    ) |>
    tidyr::drop_na(doi)

  if ("publication_date" %in% colnames(dat)) {
    dat <- dat |>
      dplyr::mutate(
        # Create a publication year variable extracted from publication date and
        # then remove the later.
        publication_year = purrr::map_int(
          publication_date,
          \(x) as.numeric(sub("^(\\d{4})-\\d{2}-\\d{2}$", "\\1", x))
        ),
        .after = id
      ) |>
      dplyr::select(!publication_date)
  }

  dat <- dplyr::select(dat, {{ vars }})

  return(dat)
}

#' Get SNSF related scientific work from databases
#'
#' @param period A numeric vector (can be a scalar) indicating the period in
#' years that must be search for scientific works (the period is defined based
#' on the minimum and maximum values in the vector).
#' @param funder_id A string with the ID of the funder. Each academic database
#' is expecting its own format:
#' -   Dimensions expects grid ID (default to SNSF grid ID: "grid.425888.b")
#' -   OpenAlex expects custom ID (default to SNSF funder ID: "F4320320924")
#' -   Crossref expects funder DOI (default to SNSF
#'     DOI: "10.13039/501100001711").
#' @param dim_token The token to connect to the Dimensions API.
#'
#' @export

get_snsf_work_dp <- function(period) {
  # Download the scientific publications available in the SNSF Data Portal
  # datasets.
  dp_publications <- readr::read_csv2(
    file.path(
      "https://data.snf.ch/exportcsv",
      "OutputdataScientificPublication.csv"
    )
  )

  dp_publications <- dp_publications |>
    dplyr::filter(
      ScientificPublication_Year %in% period,
      # Subset only peer-reviewed publications
      ScientificPublication_PeerReviewStatus == "Peer-reviewed",
      # Remove non-peer-reviewed publication types
      ScientificPublication_PeerReviewStatus != "Not peer-reviewed",
      !stringr::str_detect(ScientificPublication_Type, "non peer-review"),
    ) |>
    dplyr::mutate(
      doi = dplyr::if_else(
        is.na(ScientificPublication_DOI),
        stringr::str_extract(
          ScientificPublication_Url,
          "10\\.\\d{4,9}/[-._;()/[:alpha:][:digit:]]+"
        ),
        ScientificPublication_DOI
      )
    ) |>
    # Reformat a bit the data before returning them
    dplyr::select(
      doi,
      publication_year = ScientificPublication_Year,
      type = ScientificPublication_Type,
      id = ScientificPublicationId
    ) |>
    tidyr::drop_na(doi) |>
    add_db_to_colnames("dp")

  return(dp_publications)
}

#' @rdname get_snsf_work_dp
#' @export

get_snsf_work_dim <- function(
  period,
  funder_id = "grid.425888.b",
  dim_token = NULL
) {
  token <- token %||% get_dim_token()

  # Get the number of publications related to the SNSF in Dimensions for the
  # period of interest.
  # Setting `limit = 1` returns the first entry only, but with the number of
  # total publications in Dimensions for the performed query. It is helpful
  # to next getting all publications with pagination.
  result_count_pub <- lapply(
    period,
    \(x) {
      pre_dim_work_query(
        period = x,
        funder_id = funder_id,
        skip = 0,
        limit = 1
      ) |>
        query_dim_work(token)
    }
  )

  # Calculate how many pages with 1000 publications per page we have to
  # paginate.
  n_pages <- lapply(
    result_count_pub,
    \(x) seq(0, x[["_stats"]][["total_count"]], 1000)
  )
  # Get the publication from Dimensions using paginations (i.e. batches of 1000
  # records per page).
  dim_publications <- purrr::map(
    seq_along(period),
    \(p) {
      purrr::list_rbind(
        purrr::map(
          n_pages[[p]],
          \(x) {
            # We prepare the query for the current page
            pre_dim_work_query(
              period = period[[p]],
              funder_id = funder_id,
              skip = x
            ) |>
              # Make the query for the current page
              query_dim_work(token) |>
              # Extract the publications data from the query, which is passed to
              # the list returned by `purrr::map()`.
              purrr::pluck("publications")
          }
        )
      )
    },
    .progress = "Downloading publications data from Dimensions..."
  ) |>
    # Turning the list of data frames into a single data frame
    purrr::list_rbind()

  # Reformat a bit the data before returning them
  dim_publications <- dim_publications |>
    dplyr::select(doi, publication_year = year, type, id) |>
    add_db_to_colnames("dim")

  return(dim_publications)
}

#' @rdname get_snsf_work_dp
#' @export

get_snsf_work_oax <- function(period, funder_id = "F4320320924") {
  # The OpenAlex work types used in SNSF OA monitoring
  types <- c("article", "letter", "editorial", "review", "book", "book-chapter")

  # Prepare the query to OpenAlex for SNSF-related works
  oax_publications <- openalexR::oa_query(
    entity = "works",
    funders.id = funder_id,
    type = types,
    from_publication_date = paste0(min(period), "-01-01"),
    to_publication_date = paste0(max(period), "-12-31"),
    options = list(select = c("doi", "id", "publication_year", "type"))
  ) |>
    # Make the query with verbose to see the progression
    openalexR::oa_request(verbose = TRUE) |>
    # Turn the data returned by the request into a data frame
    openalexR::oa2df("works")

  # Reformat a bit the data before returning them
  oax_publications <- oax_publications |>
    # We remove the "https:://" prefix from the DOI as other databases do not
    # include it.
    dplyr::mutate(
      doi = purrr::map_chr(doi, \(x) sub("^https\\://doi\\.org/(.+)", "\\1", x))
    ) |>
    dplyr::select(doi, publication_year, type, id) |>
    add_db_to_colnames("oax")

  return(oax_publications)
}

#' @rdname get_snsf_work_dp
#' @export

get_snsf_work_cr <- function(period, funder_id = "10.13039/501100001711") {
  # Create a named vector with filters to apply when making the query to
  # Crossref. The name is the type of filter and the value the filter value.
  filters <- c(
    from_pub_date = paste0(min(period), "-01-01"),
    until_pub_date = paste0(max(period), "-12-31")
  )

  # The Crossref work types used in SNSF OA monitoring
  types <- c(
    "journal-article",
    "proceedings-article",
    "posted-content",
    "monograph",
    "book",
    "book-chapter",
    "edited-book"
  )

  # Set the name of each element in `types` to "type" as they will be passed as
  # filters.
  types_named <- stats::setNames(types, rep("type", length(types)))

  # Add the "types" to the filters
  filters <- c(filters, types_named)

  # Get the total amount of SNSF publications fitting in the time frame (in
  # order to later set "cursor_max" argument to it).
  result_count <- rcrossref::cr_funders(
    dois = funder_id,
    works = TRUE,
    # Apply filters (i.e. publication time frame and types)
    filter = filters,
    # Limit is 0 so we just have the number of publications to later plan
    # the collection of all publications.
    limit = 0
  ) |>
    purrr::pluck("meta") |>
    # Get the total result count of this query
    dplyr::pull(total_results)

  # Download the Crossref publications in the selected time frame. Can take
  # time, depending on the chosen time frame.
  cr_publications <- rcrossref::cr_funders(
    funder_id,
    # Everything until `cursor_max`
    cursor = "*",
    # Get all the results (we know how many from `result_count`)
    cursor_max = result_count,
    works = TRUE,
    filter = filters,
    # Only select variables that we need
    select = c(
      "DOI",
      "published",
      "published-online",
      "published-print",
      "type",
      "created"
    ),
    .progress = TRUE
  ) |>
    # Extract only the data list item
    purrr::pluck("data")

  # Reformat a bit the data before returning them
  cr_publications <- cr_publications |>
    dplyr::mutate(
      publication_date = dplyr::case_when(
        !is.na(published.online) ~ published.online,
        !is.na(published.print) ~ published.print,
        .default = created
      ),
      publication_year = purrr::map_int(
        publication_date,
        \(x) as.integer(sub("^(\\d{4}).*", "\\1", x))
      )
    ) |>
    dplyr::select(doi, publication_year, type) |>
    add_db_to_colnames("cr")

  return(cr_publications)
}
