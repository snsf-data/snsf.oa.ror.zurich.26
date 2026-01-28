# Function to get the Dimensions query with some pagination parameters Format a Dimensions query for publications

Function to get the Dimensions query with some pagination parameters
Format a Dimensions query for publications

## Usage

``` r
pre_dim_work_query(period, funder_id = "grid.425888.b", skip = 0, limit = 1000)
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

- skip:

  Integer with the number of publications to skip (useful for
  pagination).

- limit:

  Integer with the number of publications to return (useful for
  pagination).
