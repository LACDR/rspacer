# List contents of a folder, if no folder is specified the contents of the root folder will be listed.

List contents of a folder, if no folder is specified the contents of the
root folder will be listed.

## Usage

``` r
folder_tree(
  folder_id = NULL,
  ...,
  max_results = Inf,
  simplify = T,
  api_key = get_api_key()
)
```

## Arguments

- folder_id:

  Unique identifier of the folder, if NULL will return contents of the
  Workspace Home folder

- ...:

  query parameters as documented in
  <https://community.researchspace.com/public/apiDocs> \[GET
  /folders/tree\]. Can be used to order/filter the results.

- max_results:

  Maximum number of results to return.

- simplify:

  Whether to simplify the returned tibble by converting/removing columns

- api_key:

  RSpace API key

## Value

A tibble with the folder content as rows.
