# Global search for a term

Global search for a term, works identically to the simple "All" search
in RSpace Workspace. Must be \>= 3 characters long.

## Usage

``` r
document_search(query, ..., api_key = get_api_key())
```

## Arguments

- query:

  description

- ...:

  query parameters as documented in
  <https://community.researchspace.com/public/apiDocs> \[GET
  /documents\]

- api_key:

  RSpace API key

## Value

A tibble with search results, one result per row.
