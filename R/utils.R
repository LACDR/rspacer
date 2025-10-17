parse_rspace_id <- function(rspace_id) {
  rspace_id_parse_error <- glue::glue(
    "doc_id must be either an integer or character in one of the following forms:",
    "- 242392",
    "- \"242392\"",
    "- \"SD242392\"",
    "- \"GL258158\"",
    "- \"FL242398\"",
    # "- \"https://leiden.researchspace.com/globalId/SD242392\"",
    .sep = "\n"
  )
  rspace_id_regex <- "(?:SD|FL|GL)?(\\d+)$"

  # check if rspace_id is integer, or whole numeric
  if (is.integer(rspace_id) ||
    (is.numeric(rspace_id) && all.equal(rspace_id, as.integer(rspace_id)))) {
    return(rspace_id)
  }
  # if not a character -> error
  if (!is.character(rspace_id) || is_url(rspace_id)) stop(rspace_id_parse_error)
  if (!all(stringr::str_detect(rspace_id, rspace_id_regex))) {
    stop(rspace_id_parse_error)
  }
  as.integer(stringr::str_extract(rspace_id, rspace_id_regex, group = 1))
}


cli_hyperlink <- function(url, ...) {
  cli::style_hyperlink(url, url, ...)
}

is_url <- function(x) {
  tryCatch({
    httr2::url_parse(x)$scheme
    TRUE
  },
  error = function(e) return(FALSE))
}

ui_yes <- function(x, .envir = parent.frame()) {
  if (!rlang::is_interactive()) stop("User input required, but session is not interactive.")

  cli::cli_inform(x, .envir = .envir)
  qs <- c("Yes", "No")
  out <- utils::menu(qs)
  out != 0L && qs[[out]] == "Yes"
}

can_overwrite <- function(path) {
  if (!fs::file_exists(path)) {
    return(TRUE)
  }

  ui_yes("Overwrite pre-existing file {.file {path}}?")
}

add_information_to_doc_body <- function(doc_body, template_id = NULL, folder_id = NULL, tags = NULL, attachments = NULL, api_key = get_api_key()) {
  if (!is.null(template_id)) {
    form_id <- parse_rspace_id(doc_to_form_id(template_id, verbose = FALSE))
    doc_body$form <- list(id = form_id)
  }

  if (!is.null(folder_id)) {
    doc_body$parentFolderId <- parse_rspace_id(folder_id)
  }

  if (!is.null(tags)) {
    doc_body$tags <- paste(tags, collapse = ",")
  }

  if (!is.null(attachments)) {
    doc_body <- attachment_upload(doc_body, attachments, api_key)
  }

  return(doc_body)
}

retrieve_results <- function(...) {
  # retrieve_results_hateoas(...)
  retrieve_results_parallel(...)
}

retrieve_results_parallel <- function(req, key, max_results) {

  req <- req |> httr2::req_url_query(pageSize = 50)
  all_results = list()

  # Fetch first page to check total number of results
  json <- req |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  all_results <- c(all_results, json[[key]])

  total_hits <- json$totalHits
  total_pages <- ceiling(min(total_hits,max_results) / 50)
  if(total_pages > 1) {
    cli::cli_inform("Total hits: {total_hits}. Fetching additional pages...")
    # Fetch remaining pages in parallel with throttling (10 requests every 2 seconds)
    req_base <- req |> httr2::req_throttle(capacity = 10, fill_time_s = 2)
    reqs = as.list(1:(total_pages-1)) |>
      purrr::map(~ req_base |> httr2::req_url_query(pageNumber = .x))
    resps <- httr2::req_perform_parallel(reqs, progress = TRUE)
    all_results <- c(all_results, resps |>
                       purrr::map(~ httr2::resp_body_json(.x)[[key]]) |>
                       unlist(recursive = FALSE))
  }

  utils::head(all_results, max_results)
}

# Broken because of https://github.com/rspace-os/rspace-web/issues/521
retrieve_results_hateoas <- function(req, key, max_results) {

  # helper: fetch results using HATEOAS pagination
  fetch_page <- function(req) {
    json <- req |>
      httr2::req_perform() |>
      httr2::resp_body_json()

    # Extract "next" link
    next_link <- NULL
    if (!is.null(json$`_links`)) {
      for (l in json$`_links`) {
        if (l$rel == "next") {
          next_link <- l$link
          break
        }
      }
    }

    list(res = json[[key]], `next` = next_link)
  }

  # Page size: up to 50
  page_size <- if (is.finite(max_results) && max_results < 50) max_results else 50
  req <- req |> httr2::req_url_query(pageSize = page_size)

  # Fetch pages until we have enough results or there are no more pages
  all_results = list()
  repeat {
    page <- fetch_page(req)
    all_results <- c(all_results, page$res)

    if (is.null(page$`next`) || length(all_results) >= max_results) {
      break
    }
    req <- req |> httr2::req_url(page$`next`)
  }

  utils::head(all_results, max_results)
}
