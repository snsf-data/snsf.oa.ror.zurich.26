#' Get an authentication token for Dimensions API
#'
#' @param api_key A string with your API key to access Dimensions. Default is
#' set to check for a variable named "dim_api_key" in the environment variables.
#'
#' @return A token to connect to Dimensions
#' @noRd

get_dim_token <- function(api_key = Sys.getenv("dim_api_key")) {
  if (!nzchar(api_key)) {
    stop(
      "\nThe environment variable `dim_api_key` is missing.\n",
      "An API key is needed to access Dimensions and it must be stored as ",
      "an environment variable named `dim_api_key`."
    )
  }

  # Authentication URL
  auth_url <- "https://app.dimensions.ai/api/auth.json"

  # Authenticate to Dimensions to get DSL access token using API key
  auth_req <- httr::POST(
    url = auth_url,
    body = list(key = utils::URLencode(api_key)),
    encode = "json"
  )

  # Parse the authentication request response
  auth_response <- jsonlite::fromJSON(
    httr::content(auth_req, as = "text", encoding = "UTF-8")
  )

  if (any(names(auth_response) == "error")) {
    stop(
      paste0(
        "\nAuthentication to Dimensions API failed with the message: \"",
        auth_response[["error"]],
        "\""
      )
    )
  }

  # Extract and return authentication token
  return(auth_response[["token"]])
}

#' Function to get the Dimensions query with some pagination parameters
#' Format a Dimensions query for publications
#'
#' @inheritParams get_snsf_work_dim
#' @param skip Integer with the number of publications to skip (useful for
#' pagination).
#' @param limit Integer with the number of publications to return (useful for
#' pagination).
#'
#' @keywords internal

pre_dim_work_query <- function(
  period,
  funder_id = "grid.425888.b",
  skip = 0,
  limit = 1000
) {
  types <- c(
    "article",
    "book",
    "monograph",
    "chapter",
    "proceeding",
    "preprint"
  )

  # Format part of the query related to the period of interest depending on
  # whether it is spanning one or multiple years.
  if (length(period) == 1) {
    period_string <- paste0("where year = ", period)
  } else if (length(period) > 1) {
    period_string <- paste0(
      "where year in [",
      min(period),
      ":",
      max(period),
      "]"
    )
  }

  to_return <- c("id", "doi", "type", "year")

  # fmt: skip
  paste0(
    "search publications ",
    period_string,
    " and ",
    "funders = \"", funder_id, "\" ",
    "and type in [\"", paste0(types, collapse = "\", \""), "\"] ",
    "return publications[", paste0(to_return, collapse = "+"), "] ",
    "sort by year ",
    "limit ", limit,
    " skip ", skip
  )
}

#' Function to query Dimension API with DSL query
#' @keywords internal
query_dim_work <- function(query, token) {
  # DSL URL
  dsl_url <- "https://app.dimensions.ai/api/dsl.json"

  # Create POST request
  dsl_req <-
    httr::POST(
      url = dsl_url,
      body = enc2utf8(query),
      httr::add_headers(Authorization = paste("JWT", token))
    )

  # Parse the DSL request response
  dsl_response <- jsonlite::fromJSON(
    httr::content(dsl_req, as = "text", encoding = "UTF-8")
  )

  # Wait for two seconds to comply with the API limits (30 requests/minute).
  Sys.sleep(2)

  # Return successful response
  return(dsl_response)
}
