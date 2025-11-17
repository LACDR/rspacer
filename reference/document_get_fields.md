# Get the fields of a structured document as a tibble

This function retrieves the fields of a structured document and returns
them as a tibble, one row per field. As fields can contain HTML, the
tibble can be displayed prettier with, for example, the `gt` package
(see the Examples).

## Usage

``` r
document_get_fields(doc_id, api_key = get_api_key())
```

## Arguments

- doc_id:

  Unique identifier of the document

- api_key:

  RSpace API key

## Value

A tibble with the fields as rows.

## Examples

``` r
if (FALSE) { # \dontrun{
library(gt)
document_get_fields("SD123456") |> gt() |> fmt_markdown(columns = c(content))
} # }
```
