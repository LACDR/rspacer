# Convert fields list to a tibble

Convert fields list to a tibble

## Usage

``` r
fields_to_data_frame(fields, simplify = T)
```

## Arguments

- fields:

  fields list as retrieved from RSpace API

- simplify:

  Whether to simplify the returned tibble by converting/removing columns

## Value

A tibble with the fields as rows.
