#'
#' Upload a file to the gallery
#'
#' @param path file to be uploaded
#' @inheritParams api_status
#' @returns Parsed JSON response from the API.
#' @export
file_upload <- function(path, api_key = get_api_key()) {
  request() |>
    httr2::req_url_path_append("files") |>
    httr2::req_body_multipart(file = curl::form_file(path)) |>
    httr2::req_headers(`apiKey` = api_key) |>
    httr2::req_perform() |>
    httr2::resp_body_json() -> json

  cli::cli_inform("File uploaded to {.url {create_global_id_link(json$globalId)}}")

  json
}

#'
#' Download a file from the gallery
#'
#' @param file_id gallery file to be downloaded
#' @param path download destination
#' @inheritParams api_status
#' @returns The file path of the downloaded file. If the file already exists,
#'          the user is asked whether the function should overwrite the pre-existing file.
#'          If not, the download is canceled and `FALSE` is returned invisibly.
#' @export
file_download <- function(file_id, path = ".", api_key = get_api_key()) {
  if (fs::is_dir(path)) {
    # determine file name
    request() |>
      httr2::req_url_path_append("files", parse_rspace_id(file_id)) |>
      httr2::req_headers(`apiKey` = api_key) |>
      httr2::req_perform() |>
      httr2::resp_body_json() -> json

    path <- fs::path(path, json$name)
  }

  if (!can_overwrite(path)) {
    cli::cli_inform("Download cancelled")
    return(invisible(FALSE))
  }

  request() |>
    httr2::req_url_path_append("files", parse_rspace_id(file_id), "file") |>
    httr2::req_headers(`apiKey` = api_key) |>
    httr2::req_perform(path = path) |>
    httr2::resp_check_status() -> resp
  cli::cli_inform("Downloaded to {.path {resp$body}} ({file.size(resp$body)} bytes)")
  return(path)
}

attachment_upload <- function(doc_body, attachments, api_key) {
  # QC
  if (!is.data.frame(attachments)) cli::cli_abort(message = c("x" = "attachment is not provided as a tibble/data.frame"))
  if (length(setdiff(c("field", "path"), names(attachments))) > 0) cli::cli_abort(message = c("x" = "attachments df is missing the `field` or `path` column"))
  if (any(attachments$field < 1)) cli::cli_abort(message = c("x" = stringr::str_glue("attachments field number should be > 0")))
  if (any(attachments$field > length(doc_body$fields))) cli::cli_abort(message = c("x" = stringr::str_glue("attachments field is higher than the total number of fields ({length(doc_body$fields)})")))

  attachments <- attachments |>
    dplyr::distinct() |> # filter out duplicates
    dplyr::rowwise() |>
    dplyr::mutate(rspace_id = file_upload(.data$path, api_key)$id)

  attachments_res <- attachments |>
    dplyr::mutate(html = glue::glue("<fileId={.data$rspace_id}>")) |>
    dplyr::group_by(.data$field) |>
    dplyr::summarize(html = paste0(.data$html, collapse = "\n"))

  for(i in 1:nrow(attachments_res)) {
    doc_body$fields[[attachments_res$field[i]]]$content <- glue::glue(
      doc_body$fields[[attachments_res$field[i]]]$content,
      "<p><b>Attachments:</b></p>",
      attachments_res$html[i]
    )
  }

  return(doc_body)
}
