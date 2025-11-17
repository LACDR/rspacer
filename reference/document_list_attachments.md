# List attachments of a structured document

This function lists all attachments of a field in a structured document.

## Usage

``` r
document_list_attachments(
  doc_id,
  field_id = NULL,
  field_name = NULL,
  api_key = get_api_key()
)
```

## Arguments

- doc_id:

  Unique identifier of the document

- field_id:

  Specify either `field_id` or `field_name`. Identifier for the fields
  where attachments are listed. This identifier is relative, for example
  1 for the top field, 2 for the second field, etc. It is not the unique
  field identifier.

- field_name:

  Specify either `field_id` or `field_name`. The field name for which
  attachments need to be listed.

- api_key:

  RSpace API key

## Value

description A tibble with identifiers and information on attachments,
one attachment per row. Returns `FALSE` if no files are attached to the
field.
