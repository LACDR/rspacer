#' List contents of a folder, if no folder is specified the contents of the root folder will be listed.
#'
#' @param folder_id Unique identifier of the folder,
#' if NULL will return contents of the Workspace Home folder
#' @inheritParams api_status
#'
#' @returns A tibble with the folder content as rows.
#' @export
#'
folder_tree <- function(folder_id = NULL, api_key = get_api_key()) {
  path <- list("folders", "tree")
  if (!is.null(folder_id)) path <- c(path, parse_rspace_id(folder_id))

  request() |>
    httr2::req_url_path_append(path) |>
    httr2::req_headers(`apiKey` = api_key) |>
    httr2::req_perform() |>
    httr2::resp_body_json() -> json

  tibble::tibble(records = json$records) |>
    tidyr::unnest_wider("records")
}
