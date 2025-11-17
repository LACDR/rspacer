# Set the `RSPACE_API_KEY` environment variable

Sets the `RSPACE_API_KEY` environment variable to the provided RSpace
API key. To create an API key go to 'Manage API Key' section of your
profile page (MyRSpace -\> Profile).

## Usage

``` r
set_api_key(rspace_api_key)
```

## Arguments

- rspace_api_key:

  Your RSpace API key

## Value

A logical indicating if setting the API key succeeded

## Details

This will only set the environment variable for the current session, to
set it permanently, add `RSPACE_API_KEY=<your_api_key_here>` to your
`.Renviron` file, for example, using
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html).
