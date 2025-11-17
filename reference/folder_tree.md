# List contents of a folder, if no folder is specified the contents of the root folder will be listed.

List contents of a folder, if no folder is specified the contents of the
root folder will be listed.

## Usage

``` r
folder_tree(folder_id = NULL, api_key = get_api_key())
```

## Arguments

- folder_id:

  Unique identifier of the folder, if NULL will return contents of the
  Workspace Home folder

- api_key:

  RSpace API key

## Value

A tibble with the folder content as rows.
