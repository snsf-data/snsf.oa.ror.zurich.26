# SNSF publications data

Datasets with metadata from SNSF Data Portal, OpenAlex, Dimensions, and
Crossref about scientific publications published between 2020 and 2023,
resulting from Swiss National Science Foundation (SNSF) grants.
Publications from the SNSF Data Portal are publications self-reported by
grantees.

## Usage

``` r
dp_snsf_works

oax_snsf_works

dim_snsf_works

cr_snsf_works
```

## Format

### `dp_snsf_works`

A dataset with 27,652 rows and 4 columns:

- doi:

  The publication Digital Object Identifier (DOI)

- oax_publication_year:

  The publication year as available in OpenAlex

- oax_type:

  The type of publication as available in OpenAlex

- oax_id:

  The identifier of the publication in OpenAlex

### `oax_snsf_works`

A dataset with 27,652 rows and 4 columns:

- doi:

  The publication Digital Object Identifier (DOI)

- oax_publication_year:

  The publication year as available in OpenAlex

- oax_type:

  The type of publication as available in OpenAlex

- oax_id:

  The identifier of the publication in OpenAlex

### `dim_snsf_works`

A dataset with 57,079 rows and 4 columns:

- doi:

  The publication Digital Object Identifier (DOI)

- dim_publication_year:

  The publication year as available in Dimensions

- dim_type:

  The type of publication as available in Dimensions

- dim_id:

  The identifier of the publication in Dimensions

### `cr_snsf_works`

A dataset with 30,606 rows and 3 columns:

- doi:

  The publication Digital Object Identifier (DOI)

- cr_publication_year:

  The publication year as available in Crossref

- cr_type:

  The type of publication as available in Crossref
