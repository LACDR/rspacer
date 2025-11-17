# Set the `RSPACE_API_URL` environment variable

Sets the `RSPACE_API_URL` environment variable to the provided RSpace
API URL. The RSpace API URL is likely the URL of your RSpace instance
followed by `api/v1`.

## Usage

``` r
set_api_url(rspace_api_url)
```

## Arguments

- rspace_api_url:

  The RSpace API URL

## Value

A logical indicating if setting the API URL succeeded.

## Details

This will only set the environment variable for the current session, to
set it permanently, add `RSPACE_API_URL=<your_api_url_here>` to your
`.Renviron` file, for example, using
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html).

## Examples

``` r
if (FALSE) { # \dontrun{
set_api_url("https://leiden.researchspace.com/api/v1")
} # }
```
