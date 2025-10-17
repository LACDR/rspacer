#' Get document from RSpace based on document ID
#'
#' @param doc_id Unique identifier of the document
#' @inheritParams api_status
#'
#' @returns An RSpace document as parsed JSON.
#' @export
#'
document_retrieve <- function(doc_id, api_key = get_api_key()) {
  request() |>
    httr2::req_url_path_append("documents", parse_rspace_id(doc_id)) |>
    httr2::req_headers(`apiKey` = api_key) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}

document_post <- function(body, api_key = get_api_key()) {
  if(getOption("rspacer.set_rspacer_tag", TRUE))
    body$tags <- paste0(c("rspacer", body$tags), collapse = ",")

  request() |>
    httr2::req_url_path_append("documents") |>
    httr2::req_headers(`apiKey` = api_key) |>
    httr2::req_body_json(body) |>
    httr2::req_perform() |>
    httr2::resp_body_json() -> json

  cli::cli_inform("Document created: {.url {create_global_id_link(json$globalId)}}")

  json
}

document_put <- function(body, existing_document_id, api_key = get_api_key()) {
  if(getOption("rspacer.set_rspacer_tag", TRUE)) {
    if(is.null(body$tags)) {
      body$tags <- "rspacer"
    } else {
      body$tags <- ifelse("rspacer" %in% stringr::str_split_1(body$tags, ","),
                          body$tags,
                          paste0(c("rspacer", body$tags), collapse = ","))
    }
  }

  request() |>
    httr2::req_url_path_append("documents", parse_rspace_id(existing_document_id)) |>
    httr2::req_headers(`apiKey` = api_key) |>
    httr2::req_body_json(body) |>
    httr2::req_method("PUT") |>
    httr2::req_perform() |>
    httr2::resp_body_json() -> json

  cli::cli_inform("Document updated: {.url {create_global_id_link(json$globalId)}}")

  return(json)
}

#'
#' Global search for a term
#'
#' Global search for a term, works identically to the simple "All" search in RSpace Workspace.
#' Query term must be >= 3 characters long.
#'
#' @param query description
#' @param ... query parameters as documented in
#' <https://community.researchspace.com/public/apiDocs> \[GET /documents\]
#' Can be used to order/filter the results.
#' @param max_results Maximum number of results to return.
#' @param simplify Whether to simplify the returned tibble by converting/removing columns
#' Use `Inf` to return all results (may take a while).
#' @inheritParams api_status
#'
#' @returns A tibble with search results, one result per row.
#' @export
document_search <- function(query, ..., max_results = 50, simplify = T, api_key = get_api_key()) {

  req <- request() |>
    httr2::req_url_path_append("documents") |>
    httr2::req_url_query(query = query, ...) |>
    httr2::req_headers(`apiKey` = get_api_key())

  documents <- retrieve_results(req, "documents", max_results)

  doc_tibble <- tibble::tibble(documents = documents) |>
    tidyr::unnest_wider("documents")

  if(nrow(doc_tibble) > 0 && simplify) {
    doc_tibble <- doc_tibble |>
      dplyr::select(-"signed", -"_links") |>
      dplyr::mutate(
        form = purrr::map_chr(.data$form, ~ .x$name),
        owner = purrr::map_chr(.data$owner, ~ paste(.x$firstName, .x$lastName)),
        created = lubridate::as_datetime(.data$created),
        lastModified = lubridate::as_datetime(.data$lastModified)
      )
  }

  doc_tibble
}

#'
#' Get the form id used for a document
#'
#' @param verbose whether to print the matching document/form
#' @inheritParams document_retrieve
#' @returns A form id.
#' @export
doc_to_form_id <- function(doc_id, verbose = TRUE, api_key = get_api_key()) {
  json <- document_retrieve(doc_id, api_key)
  if (verbose) {
    cli::cli_inform(c(
      "{.field Document}: {json$globalId} ({json$name})",
      "{.field Form}:\t {json$form$globalId} ({json$form$name})"
    ))
  }
  json$form$globalId
}

#'
#' List attachments of a structured document
#'
#' This function lists all attachments of a field in a structured document.
#'
#' @param doc_id Unique identifier of the document
#' @inheritParams api_status
#' @returns description A tibble with identifiers and information on attachments, one attachment per row.
#' Returns an empty tibble if no files are attached to the field.
#' @export
document_list_attachments <- function(doc_id, api_key = get_api_key()) {
  if (is.null(doc_id)) cli::cli_abort("Specify the document identifier `doc_id`")

  attachments <- document_get_fields(doc_id) |>
    tibble::rowid_to_column(var = "field_id") |>
    dplyr::select("field_id", field_name = "name", "files") |>
    tidyr::drop_na("files")

  if(nrow(attachments) == 0) {
    return(attachments)
  }

  attachments |>
    tidyr::unnest_longer("files") |>
    tidyr::unnest_wider("files") |>
    dplyr::select(-"_links")

}

#'
#' Add attachments to existing document
#'
#' @param doc_id Unique identifier of the document
#' @param attachments attachments to attach to the fields in tibble/data.frame
#' form (one attachment per row), e.g., `tibble(field = 7, path = "file.txt")`
#' @inheritParams api_status
#'
#' @returns
#' A JSON object, invisibly. The function will raise an error if `doc_id` is not specified.
#'
#' @export
document_add_attachments <- function(doc_id, attachments, api_key = get_api_key()) {
  if (is.null(doc_id)) cli::cli_abort("Specify the document identifier `doc_id`")

  doc_body <- list()
  doc_body$fields <- document_retrieve(doc_id, api_key)$fields
  doc_body <- add_information_to_doc_body(doc_body, attachments = attachments, api_key = api_key)

  json <- document_put(doc_body, doc_id)

  return(invisible(json))

}
