# Get SNSF OA monitoring data from Github

Get SNSF OA monitoring data from Github

## Usage

``` r
get_snsf_oa_work(
  repo,
  file,
  url = "https://raw.githubusercontent.com/snsf-data/",
  vars = c("doi", "id", "publication_year", "type")
)
```

## Arguments

- repo:

  The name of the OA monitoring repository.

- file:

  The name of the data file.

- url:

  The url where is stored the raw content of the SNSF Github page
  (default to "https://raw.githubusercontent.com/snsf-data/").

- vars:

  A vector with the name of the variable to keep from the SNSF Data
  Portal.

## Value

A data frame.
