# Functions to process RSpace structured document fields

data_frame_to_fields <- function(fields_df) {
  col_names <- colnames(fields_df)

  # Convert each row of the data frame into a list using the column names
  fields <- apply(fields_df, 1, function(row) {
    row_list <- as.list(row)
    names(row_list) <- col_names
    row_list
  })
  fields <- as.list(fields)

  # The API wants a plain array -> remove the names
  names(fields) <- NULL

  return(fields)
}

#' Convert fields list to a tibble
#'
#' @param fields fields list as retrieved from RSpace API
#' @param simplify Whether to simplify the returned tibble by converting/removing columns
#' @returns A tibble with the fields as rows.
#' @export
fields_to_data_frame <- function(fields, simplify = T) {
  res <- tibble::tibble(fields = fields) |>
    tidyr::unnest_wider("fields")
  if(nrow(res) > 0 && simplify) {
    if("lastModified" %in% colnames(res)) {
      res <- res |>
        dplyr::mutate(lastModified = lubridate::as_datetime(.data$lastModified))
    }
  }
  res
}

#' Get the fields of a structured document as a tibble
#'
#' This function retrieves the fields of a structured document and returns them
#' as a tibble, one row per field. As fields can contain HTML, the tibble can be
#' displayed prettier with, for example, the `gt` package (see the Examples).
#'
#' @param doc_id Unique identifier of the document
#' @inheritParams api_status
#' @returns A tibble with the fields as rows.
#' @export
#' @examples
#' \dontrun{
#' library(gt)
#' document_get_fields("SD123456") |> gt() |> fmt_markdown(columns = c(content))
#' }
document_get_fields <- function(doc_id, api_key = get_api_key()) {
  doc <- document_retrieve(doc_id, api_key)
  fields_to_data_frame(doc$fields)
}

#' Put a list of all fields into one field.
#'
#' This can be needed when no Structured Document template is specified and a
#' Basic Document is used, but the html/excel/other input has multiple
#' subheaders or fields.
#'
#' @keywords internal
#' @param doc_body_fields multiple fields in a list
#' @returns a list with one field containing all content from all fields
put_all_fields_in_one_field <- function(doc_body_fields) {
  text_content <- fields_to_data_frame(doc_body_fields)

  # Add html structure
  text_content <- text_content |>
    dplyr::mutate(content = paste0(
      "<h2>", as.character(.data$name), "</h2>",
      "<p>", as.character(.data$content), "</p>"
    ))

  # Collapse content into one field
  text_content <- text_content |>
    dplyr::pull(.data$content) |>
    paste(collapse = "\n")

  return(list(list("content" = text_content)))
}
