# Upload a html document to RSpace

This function can upload a html document (e.g., generated from quarto)
to an RSpace Basic Document, or to a Structured Document if the template
is also provided.

## Usage

``` r
document_create_from_html(
  path,
  template_id = NULL,
  folder_id = NULL,
  tags = NULL,
  attachments = NULL,
  existing_document_id = NULL,
  api_key = get_api_key()
)
```

## Arguments

- path:

  html document to upload

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
