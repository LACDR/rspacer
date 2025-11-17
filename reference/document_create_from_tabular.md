# Upload tabular data to RSpace

This function can upload tabular data (data.frame/tibble) to an RSpace
structured document. The tabular needs to have exactly two columns, one
with the RSpace structured document fields and one with the content.

## Usage

``` r
document_create_from_tabular(
  df,
  document_name = NULL,
  template_id = NULL,
  folder_id = NULL,
  tags = NULL,
  attachments = NULL,
  existing_document_id = NULL,
  api_key = get_api_key()
)
```

## Arguments

- df:

  tabular data to upload.

- document_name:

  specify the name of the RSpace entry. If not specified, it will be the
  value in Title, Name, title, or name if that is one of the fields in
  the Excel document. If that does not exist, it will be the file name.

- template_id:

  document id of the RSpace template used. Will be overwritten by the
  template of `existing_document_id` if specified. A basic document is
  created if no template is specified.

- folder_id:

  folder_id in which the document will be created (can be a notebook)

- tags:

  vector of tags to apply to the document (will include "rspacer" by
  default)

- attachments:

  attachments to attach to the fields in tibble/data.frame form (one
  attachment per row), e.g., `tibble(field = 7, path = "file.txt")`

- existing_document_id:

  document id of a document to be replaced, if NULL (the default) a new
  document will be created.

- api_key:

  RSpace API key

## Value

Invisible JSON response from the API.
