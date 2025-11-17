# Download a file from the gallery

Download a file from the gallery

## Usage

``` r
file_download(file_id, path = ".", api_key = get_api_key())
```

## Arguments

- file_id:

  gallery file to be downloaded

- path:

  download destination

- api_key:

  RSpace API key

## Value

The file path of the downloaded file. If the file already exists, the
user is asked whether the function should overwrite the pre-existing
file. If not, the download is canceled and `FALSE` is returned
invisibly.
