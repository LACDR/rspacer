# Put a list of all fields into one field.

This can be needed when no Structured Document template is specified and
a Basic Document is used, but the html/excel/other input has multiple
subheaders or fields.

## Usage

``` r
put_all_fields_in_one_field(doc_body_fields)
```

## Arguments

- doc_body_fields:

  multiple fields in a list

## Value

a list with one field containing all content from all fields
