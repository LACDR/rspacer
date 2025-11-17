# Add attachments to existing document

Add attachments to existing document

## Usage

``` r
document_add_attachments(doc_id, attachments, api_key = get_api_key())
```

## Arguments

- doc_id:

  Unique identifier of the document

- attachments:

  attachments to attach to the fields in tibble/data.frame form (one
  attachment per row), e.g., `tibble(field = 7, path = "file.txt")`

- api_key:

  RSpace API key

## Value

A JSON object, invisibly. The function will raise an error if `doc_id`
is not specified.
