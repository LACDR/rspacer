# List attachments of a structured document

This function lists all attachments of a field in a structured document.

## Usage

``` r
document_list_attachments(doc_id, api_key = get_api_key())
```

## Arguments

- doc_id:

  Unique identifier of the document

- api_key:

  RSpace API key

## Value

description A tibble with identifiers and information on attachments,
one attachment per row. Returns an empty tibble if no files are attached
to the field.
