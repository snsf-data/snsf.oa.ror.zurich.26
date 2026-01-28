# Get SNSF related scientific work from databases

Get SNSF related scientific work from databases

## Usage

``` r
get_snsf_work_dp(period)

get_snsf_work_dim(period, funder_id = "grid.425888.b", dim_token = NULL)

get_snsf_work_oax(period, funder_id = "F4320320924")

get_snsf_work_cr(period, funder_id = "10.13039/501100001711")
```

## Arguments

- period:

  A numeric vector (can be a scalar) indicating the period in years that
  must be search for scientific works (the period is defined based on
  the minimum and maximum values in the vector).

- funder_id:

  A string with the ID of the funder. Each academic database is
  expecting its own format:

  - Dimensions expects grid ID (default to SNSF grid ID:
    "grid.425888.b")

  - OpenAlex expects custom ID (default to SNSF funder ID:
    "F4320320924")

  - Crossref expects funder DOI (default to SNSF DOI:
    "10.13039/501100001711").

- dim_token:

  The token to connect to the Dimensions API.
