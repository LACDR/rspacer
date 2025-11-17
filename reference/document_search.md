# Global search for a term

Global search for a term, works identically to the simple "All" search
in RSpace Workspace. Query term must be \>= 3 characters long.

## Usage

``` r
document_search(
  query,
  ...,
  max_results = 50,
  simplify = T,
  api_key = get_api_key()
)
```

## Arguments

- query:

  description

- ...:

  query parameters as documented in
  <https://community.researchspace.com/public/apiDocs> \[GET
  /documents\] Can be used to order/filter the results.

- max_results:

  Maximum number of results to return.

- simplify:

  Whether to simplify the returned tibble by converting/removing columns
  Use `Inf` to return all results (may take a while).

- api_key:

  RSpace API key

## Value

A tibble with search results, one result per row.
