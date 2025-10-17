
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rspacer

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rspacer)](https://CRAN.R-project.org/package=rspacer)
[![R-CMD-check](https://github.com/LACDR/rspacer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/LACDR/rspacer/actions/workflows/R-CMD-check.yaml)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![FAIR checklist
badge](https://fairsoftwarechecklist.net/badge.svg)](https://fairsoftwarechecklist.net/v0.2/?f=31&a=31113&i=32300&r=133)
<!-- badges: end -->

The rspacer package is a wrapper for the RSpace Electronic Lab Notebook
(<https://www.researchspace.com/>) API
(<https://community.researchspace.com/public/apiDocs>).

This packages provides convenience functions to browse, search, create,
and edit your RSpace documents. In addition, it enables filling RSpace
templates from R Markdown/Quarto reports or from tabular data (e.g., R
data.frames/tibbles, but also Excel/CSV files), which should
significantly speed up documentation of computational/analysis workflows
in the RSpace ELN, and will enable integration of the RSpace ELN in
R-based tools such as R Shiny apps.

For a more extensive description of rspacer’s applications see our
manuscript at <https://lacdr.github.io/rspacer-manuscript/>. For
documentation and user guides see below.

## Installation

``` r
# Install rspacer from CRAN:
install.packages("rspacer")

# Or the development version from GitHub:
# install.packages("pak")
pak::pak("lacdr/rspacer")
```

## Usage

See the [Get
started](https://lacdr.github.io/rspacer/articles/rspacer.html) article
how to use this package.
