.onLoad <- function(libname, pkgname) {
  op <- options()
  op.rspacer <- list(
    rspacer.set_rspacer_tag = TRUE
  )
  toset <- !(names(op.rspacer) %in% names(op))
  if (any(toset)) options(op.rspacer[toset])

  invisible()
}
