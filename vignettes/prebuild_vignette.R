# Thanks to https://ropensci.org/blog/2019/12/08/precompute-vignettes/
knitr::knit("vignettes/rspacer.qmd.in", output = "vignettes/rspacer.qmd")
knitr::knit("vignettes/articles/create_document_from_html.qmd.in",
            output = "vignettes/articles/create_document_from_html.qmd")
knitr::knit("vignettes/articles/create_document_from_table.qmd.in",
            output = "vignettes/articles/create_document_from_table.qmd")

