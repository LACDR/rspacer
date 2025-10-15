
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
badge](https://fairsoftwarechecklist.net/badge.svg)](https://fairsoftwarechecklist.net/v0.2?f=31&a=31113&i=32300&r=133)
<!-- badges: end -->

The goal of rspacer is to wrap the [RSpace
API](https://community.researchspace.com/public/apiDocs), that is, allow
you to use the API directly from R using convenience functions.

## Installation

You can install the development version of rspacer with

``` r
remotes::install_github("lacdr/rspacer")
```

## Usage

See the [Get
started](https://lacdr.github.io/rspacer/articles/rspacer.html) article
how to use this package.

**NB:** API Paging/rate limiting is not properly handled yet, but this
can be worked around.
