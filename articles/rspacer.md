# Introduction to rspacer

The rspacer package is a wrapper for the RSpace Electronic Lab Notebook
(<https://www.researchspace.com/>) API
(<https://community.researchspace.com/public/apiDocs>), and packages
provides convenience functions to browse, search, create, and edit your
RSpace documents. In addition, it enables filling RSpace templates from
R Markdown/Quarto reports or from tabular data (e.g., R
data.frames/tibbles, but also Excel/CSV files).

This vignette will show you how to get started with rspacer.

## Setting up rspacer

To use rspacer it needs two things:

1.  The API URL for your RSpace instance (this is typically the URL of
    your RSpace instance followed by `api/v1`, e.g.,
    `https://leiden.researchspace.com/api/v1`)[¹](#fn1)
2.  Your API key, which is an authentication token you can use instead
    of your username and password. To create an API key go to ‘Manage
    API Key’ section of your RSpace profile page (MyRSpace -\> My
    Profile). **You should keep your API key private.** You can
    regenerate an API key at any time, which will invalidate the old
    key.

You can use the
[`set_api_url()`](https://lacdr.github.io/rspacer/reference/set_api_url.md)
and
[`set_api_key()`](https://lacdr.github.io/rspacer/reference/set_api_key.md)
functions to make these available to rspacer in the current session. To
make this information persistent you can store it in environment
variables. An easy way to do this is with
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html);
in the file that opens, you should add the following lines (insert your
own URL and key):

    RSPACE_API_URL="https://leiden.researchspace.com/api/v1"
    RSPACE_API_KEY="<YOUR_API_KEY_HERE>"

After saving the file and restarting R, you should now be able to run

``` r
library(rspacer)
api_status()
```

    ## $message
    ## [1] "OK"
    ##
    ## $rspaceVersion
    ## [1] "1.115.2"

## Functionality

### Folders

Now you can use rspacer to interact with your RSpace Workspace. For
example,
[`folder_tree()`](https://lacdr.github.io/rspacer/reference/folder_tree.md)
will show you the content of your Workspace as a tibble:

``` r
folder_tree()
```

    ## # A tibble: 10 × 7
    ##        id globalId name                   created             lastModified        type     owner
    ##     <int> <chr>    <chr>                  <dttm>              <dttm>              <chr>    <chr>
    ##  1 356307 SD356307 Gerhard Burger         2024-01-17 14:56:22 2024-01-17 15:04:39 DOCUMENT Gerhard Burger
    ##  2 260004 FL260004 LACDR RDM              2023-11-06 10:19:59 2023-11-06 10:19:59 FOLDER   Gerhard Burger
    ##  3 242175 FL242175 GABi001_EMP_regulation 2023-05-30 10:14:51 2023-06-14 12:30:47 FOLDER   Gerhard Burger
    ##  4 242400 FL242400 Ontologies             2023-06-01 07:23:10 2023-06-01 07:23:10 FOLDER   Gerhard Burger
    ##  5 242398 FL242398 Api Inbox              2023-06-01 07:23:08 2023-06-01 07:23:08 FOLDER   Gerhard Burger
    ##  6 242182 FL242182 Publications           2023-05-30 11:07:25 2023-05-30 11:07:25 FOLDER   Gerhard Burger
    ##  7  21961 FL21961  DDS2 Data management   2023-03-16 09:50:33 2023-03-16 09:50:33 FOLDER   Gerhard Burger
    ##  8   7833 FL7833   Templates              2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER   Gerhard Burger
    ##  9   7819 GF7819   Gallery                2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER   Gerhard Burger
    ## 10   7814 FL7814   Shared                 2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER   Gerhard Burger

You can also specify an id or Unique ID (`globalId`) to show the
contents of a specific folder:

``` r
folder_tree(7819)
```

    ## # A tibble: 8 × 7
    ##      id globalId name          created             lastModified        type   owner
    ##   <int> <chr>    <chr>         <dttm>              <dttm>              <chr>  <chr>
    ## 1  7828 GF7828   Snippets      2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER Gerhard Burger
    ## 2  7827 GF7827   PdfDocuments  2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER Gerhard Burger
    ## 3  7826 GF7826   Miscellaneous 2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER Gerhard Burger
    ## 4  7825 GF7825   Documents     2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER Gerhard Burger
    ## 5  7824 GF7824   Chemistry     2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER Gerhard Burger
    ## 6  7823 GF7823   Videos        2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER Gerhard Burger
    ## 7  7822 GF7822   Audios        2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER Gerhard Burger
    ## 8  7820 GF7820   Images        2022-12-22 12:32:22 2022-12-22 12:32:22 FOLDER Gerhard Burger

### Documents

#### Search

You can search for documents using the
[`document_search()`](https://lacdr.github.io/rspacer/reference/document_search.md)
function:

``` r
document_search("test")
```

    ## # A tibble: 50 × 11
    ##        id globalId name          created             lastModified        parentFolderId grandParentId tags
    ##     <int> <chr>    <chr>         <dttm>              <dttm>                       <int>         <int> <chr>
    ##  1 426750 SD426750 Untitled doc… 2025-11-18 14:04:50 2025-11-18 14:04:56         242398          7813 rspa…
    ##  2 426748 SD426748 Untitled doc… 2025-11-18 13:55:13 2025-11-18 13:55:19         242398          7813 rspa…
    ##  3 426716 SD426716 Untitled doc… 2025-11-18 12:15:15 2025-11-18 12:15:20         242398          7813 rspa…
    ##  4 426660 SD426660 251117_colle… 2025-11-17 16:13:27 2025-11-18 09:24:17             NA            NA <NA>
    ##  5 426662 SD426662 251120_test_… 2025-11-17 16:17:44 2025-11-17 16:23:49             NA            NA <NA>
    ##  6 424078 SD424078 test          2025-10-17 10:21:21 2025-10-17 10:21:27         242398          7813 rspa…
    ##  7 424072 SD424072 test          2025-10-17 09:21:55 2025-10-17 09:22:01         242398          7813 rspa…
    ##  8 422915 SD422915 251001_test_… 2025-09-30 08:33:22 2025-10-07 11:51:30             NA            NA <NA>
    ##  9 421333 SD421333 250901_compa… 2025-09-01 09:06:12 2025-09-10 13:16:24             NA            NA <NA>
    ## 10 420651 SD420651 250820_Suriv… 2025-08-19 14:34:17 2025-09-09 12:37:52             NA            NA <NA>
    ## # ℹ 40 more rows
    ## # ℹ 3 more variables: tagMetaData <chr>, form <chr>, owner <chr>

#### Retrieve

You can retrieve documents using

``` r
res <- document_retrieve("SD356307")
summary(res)
```

    ##                Length Class  Mode
    ## id              1     -none- numeric
    ## globalId        1     -none- character
    ## name            1     -none- character
    ## created         1     -none- character
    ## lastModified    1     -none- character
    ## parentFolderId  1     -none- numeric
    ## signed          1     -none- logical
    ## tags            0     -none- NULL
    ## tagMetaData     0     -none- NULL
    ## form           10     -none- list
    ## owner          10     -none- list
    ## fields          8     -none- list
    ## _links          1     -none- list
    ## grandParentId   1     -none- numeric

The result is json converted to an R list, to get the field information
you could use

``` r
library(tidyverse)
(res$fields |>
  fields_to_data_frame() -> res_df)
```

    ## # A tibble: 8 × 10
    ##        id globalId  name       type  content lastModified        columnIndex files listOfMaterials `_links`
    ##     <int> <chr>     <chr>      <chr> <chr>   <dttm>                    <int> <lgl> <lgl>           <lgl>
    ## 1 1873444 FD1873444 Template … stri… "LACDR… 2024-01-17 14:56:22           0 NA    NA              NA
    ## 2 1873445 FD1873445 Name       stri… "Gerha… 2024-01-17 14:56:39           1 NA    NA              NA
    ## 3 1873446 FD1873446 Email      stri… "g.a.b… 2024-01-17 14:57:02           2 NA    NA              NA
    ## 4 1873447 FD1873447 Phone      stri… ""      2024-01-17 14:56:22           3 NA    NA              NA
    ## 5 1873448 FD1873448 ORCID      stri… "0000-… 2024-01-17 14:59:29           4 NA    NA              NA
    ## 6 1873449 FD1873449 Address    text  "<p><a… 2024-01-17 14:57:49           5 NA    NA              NA
    ## 7 1873450 FD1873450 Affiliati… stri… "Leide… 2024-01-17 14:59:13           6 NA    NA              NA
    ## 8 1873451 FD1873451 Roles      text  ""      2024-01-17 14:56:22           7 NA    NA              NA

Since the fields typically contain HTML formatted information, this can
be better displayed using the [`gt`](https://gt.rstudio.com/) package:

``` r
library(gt)
res_df |>
  gt() |>
  fmt_markdown(columns = c(content))
```

[TABLE]

#### Create

To create a document you need to specify name and content of the fields
to be created. The simplest way to do this is specify these in tabular
form:

``` r
doc_df_to_upload <- tribble(
~name, ~content,
"Example field", "Example content"
)
document_create_from_tabular(df = doc_df_to_upload, document_name = "Example document")
```

    ## Document created: <https://leiden.researchspace.com/globalId/SD426761>

Support for multiple fields is supported if a compatible RSpace template
is provided with the `template_id` argument; if `template_id = NULL` all
fields will be concatenated into a single field using the field names as
section headers. The Articles tab contains more detailed instructions on
how to create more structured documents in RSpace using the rspacer
`document_create_*` functions and their arguments.

##### The `rspacer` document tag

By default rspacer tags all RSpace documents created/updated using
rspacer functions with the `rspacer` tag. To disable this[²](#fn2), use
the following code:

``` r
options(rspacer.set_rspacer_tag = F)
```

------------------------------------------------------------------------

1.  If you don’t have an RSpace instance yet, you can use the
    <https://community.researchspace.com/> instance.

2.  this might be necessary on instances that enforce controlled
    vocabularies for tags
