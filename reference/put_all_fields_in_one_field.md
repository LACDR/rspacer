# Put a list of all fields into one field.

This can be needed when no Structured Document template is specified and
a Basic Document is used, but the html/excel/other input has multiple
subheaders or fields.

## Usage

``` r
put_all_fields_in_one_field(doc_body_fields, use_html_sep = TRUE)
```

## Arguments

- doc_body_fields:

  multiple fields in a list

- use_html_sep:

  If `TRUE`, each field is placed in a html paragraph

## Value

a list with one field, with only content, all contents from other
fields, separated by `\n`.
