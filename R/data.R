#' SNSF publications data
#'
#' @description
#' Datasets with metadata from SNSF Data Portal, OpenAlex, Dimensions, and
#' Crossref about scientific publications published between 2020 and 2023,
#' resulting from Swiss National Science Foundation (SNSF) grants. Publications
#' from the SNSF Data Portal are publications self-reported by grantees.
#'
#' @format ## `dp_snsf_works`
#' A dataset with 27,652 rows and 4 columns:
#' \describe{
#'  \item{doi}{The publication Digital Object Identifier (DOI)}
#'  \item{oax_publication_year}{The publication year as available in OpenAlex}
#'  \item{oax_type}{The type of publication as available in OpenAlex}
#'  \item{oax_id}{The identifier of the publication in OpenAlex}
#' }
"dp_snsf_works"

#' @rdname dp_snsf_works
#' @format ## `oax_snsf_works`
#' A dataset with 27,652 rows and 4 columns:
#' \describe{
#'  \item{doi}{The publication Digital Object Identifier (DOI)}
#'  \item{oax_publication_year}{The publication year as available in OpenAlex}
#'  \item{oax_type}{The type of publication as available in OpenAlex}
#'  \item{oax_id}{The identifier of the publication in OpenAlex}
#' }
"oax_snsf_works"

#' @rdname dp_snsf_works
#' @format ## `dim_snsf_works`
#' A dataset with 57,079 rows and 4 columns:
#' \describe{
#'  \item{doi}{The publication Digital Object Identifier (DOI)}
#'  \item{dim_publication_year}{The publication year as available in Dimensions}
#'  \item{dim_type}{The type of publication as available in Dimensions}
#'  \item{dim_id}{The identifier of the publication in Dimensions}
#' }
"dim_snsf_works"

#' @rdname dp_snsf_works
#' @format ## `cr_snsf_works`
#' A dataset with 30,606 rows and 3 columns:
#' \describe{
#'  \item{doi}{The publication Digital Object Identifier (DOI)}
#'  \item{cr_publication_year}{The publication year as available in Crossref}
#'  \item{cr_type}{The type of publication as available in Crossref}
#' }
"cr_snsf_works"
