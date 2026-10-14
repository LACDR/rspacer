# Thanks to https://ropensci.org/blog/2019/12/08/precompute-vignettes/
prebuild_vignette <- function(path) {
  callr::r(
    function(p) {
      pkgload::load_all(".", quiet = TRUE)
      knitr::knit(p, output = fs::path_ext_remove(p))
    },
    args = list(p = path),
    show = TRUE
  )
}

prebuild_vignette("vignettes/rspacer.qmd.in")
prebuild_vignette("vignettes/articles/create_document_from_html.qmd.in")
prebuild_vignette("vignettes/articles/create_document_from_table.qmd.in")

