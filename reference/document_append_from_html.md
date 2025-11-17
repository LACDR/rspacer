# Add html content to an existing RSpace document

Append a html document (e.g., generated from quarto) to an RSpace
structured document. This function retrieves the current document, and
adds text to fields specified by h2 html headers.

## Usage

``` r
document_append_from_html(
  path,
  existing_document_id,
  tags = NULL,
  attachments = NULL,
  allow_missing_fields = FALSE,
  api_key = get_api_key()
)
```

## Arguments

- path:

  html document to upload

- existing_document_id:

  document identifier of the current RSpace document.

- tags:

  vector of tags to apply to the document (will include "rspacer" by
  default)

- attachments:

  attachments to attach to the fields in tibble/data.frame form (one
  attachment per row), e.g., `tibble(field = 7, path = "file.txt")`

- allow_missing_fields:

  Specify if a mismatch in fields is allowed. If this is `FALSE`, the
  html fields cannot be appended to the RSpace document when fields are
  missing. If it is `TRUE`, only fields with the same name as in the
  template will be appended.

- api_key:

  RSpace API key

## Value

Invisible JSON response from the API.
