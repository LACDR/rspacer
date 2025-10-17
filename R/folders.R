#' List contents of a folder, if no folder is specified the contents of the root folder will be listed.
#'
#' @param folder_id Unique identifier of the folder,
#' if NULL will return contents of the Workspace Home folder
#' @param ... query parameters as documented in
#' <https://community.researchspace.com/public/apiDocs> \[GET /folders/tree\].
#' Can be used to order/filter the results.
#' @param max_results Maximum number of results to return.
#' @param simplify Whether to simplify the returned tibble by converting/removing columns
#' @inheritParams api_status
#'
#' @returns A tibble with the folder content as rows.
#' @export
#'
folder_tree <- function(folder_id = NULL, ..., max_results = Inf, simplify = T, api_key = get_api_key()) {
  path <- list("folders", "tree")
  if (!is.null(folder_id)) path <- c(path, parse_rspace_id(folder_id))

  req <- request() |>
    httr2::req_url_path_append(path) |>
    httr2::req_headers(`apiKey` = api_key)

  records <- retrieve_results(req, "records", max_results)

  rec_tibble <- tibble::tibble(records = records) |>
    tidyr::unnest_wider("records")

  if(nrow(rec_tibble) > 0 && simplify) {
    rec_tibble <- rec_tibble |>
      dplyr::select(-"parentFolderId", -"_links") |>
      dplyr::mutate(
        owner = purrr::map_chr(.data$owner, ~ paste(.x$firstName, .x$lastName)),
        created = lubridate::as_datetime(.data$created),
        lastModified = lubridate::as_datetime(.data$lastModified)
      )
  }

  rec_tibble
}
