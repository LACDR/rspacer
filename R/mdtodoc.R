html_to_doc_body <- function(path, verbose = TRUE) {
  xml <- xml2::read_html(path)
  title <- rvest::html_element(xml, xpath = "//title") |> rvest::html_text()

  # Select sections that have a h2 child
  sections <- rvest::html_elements(xml, xpath = "//body//section[h2]")

  section_content <- purrr::map(sections, rvest::html_children)
  section_heading <- purrr::map(section_content, ~ rvest::html_text(.x[1]))
  section_content <- purrr::map(section_content, ~ .x[-1]) #< remove heading
  names(section_content) <- section_heading

  if (verbose) {
    cli::cli_inform("{.field Title}: {title}")
    purrr::iwalk(section_heading, ~ cli::cli_inform("{.field - Section {.y}}: {.x}"))
  }

  fields <- purrr::imap(section_content, ~ list(
    name = .y,
    content = .x
  ))

  list(
    name = title,
    fields = fields
  )
}

create_rspace_document_name <- function(path, sections, document_name = NULL) {
  # If a name is already supplied, just use that
  if (!is.null(document_name)) {
    if (!is.character(document_name)) cli::cli_abort(message = c("x" = "Document name should be a character string or NULL"))
    return(document_name)
  }

  # Otherwise, test if any sections are named title or name (case-insensitive)
  detected <- stringr::str_detect(sections$name, stringr::regex("title|name", ignore_case = TRUE))
  if (any(detected)) {
    # Return first field that matches
    return(sections$content[detected][1])
  }

  # Otherwise just return the filename without extension
  return(path |> fs::path_file() |> fs::path_ext_remove())
}

tabfile_to_doc_body <- function(path, document_name = NULL, verbose = TRUE, file_type = NULL) {
  if (!file.exists(path)) cli::cli_abort(message = c("x" = glue::glue("File not found: {path}")))
  if (is.null(file_type)) {
    file_type <- fs::path_ext(path)
  }
  if (!file_type %in% c("xlsx", "csv", "tsv")) cli::cli_abort(message = c("x" = glue::glue("file_type is {file_type}. It should be xlsx, csv or tsv. Specify file_type manually or rename the input file.")))
  sections <- switch(file_type,
    "xlsx" = readxl::read_xlsx(path, col_names = c("name", "content"), col_types = "text"),
    "csv" = readr::read_csv(path, col_names = c("name", "content"), col_types = "cc", show_col_types = FALSE),
    "tsv" = readr::read_tsv(path, col_names = c("name", "content"), col_types = "cc", show_col_types = FALSE)
  )
  # Set the RSpace entry title
  title <- create_rspace_document_name(path, sections, document_name)

  if (verbose) {
    cli::cli_inform("{.field Title}: {title}")
    purrr::iwalk(sections[["name"]], ~ cli::cli_inform("{.field - Section {.y}}: {.x}"))
  }
  # Get a list as required by RSpace
  fields <- data_frame_to_fields(sections)
  list(
    name = title,
    fields = fields
  )
}

#' Upload a html document to RSpace
#'
#' This function can upload a html document (e.g., generated from quarto) to an
#' RSpace Basic Document, or to a Structured Document if the template is also provided.
#'
#' @param path html document to upload
#' @param template_id document id of the RSpace template used.
#' Will be overwritten by the template of `existing_document_id` if specified.
#' A basic document is created if no template is specified.
#' @param folder_id folder_id in which the document will be created (can be a notebook)
#' @param tags vector of tags to apply to the document (will include "rspacer" by default)
#' @param attachments attachments to attach to the fields in tibble/data.frame form (one attachment per row), e.g., `tibble(field = 7, path = "file.txt")`
#' @param existing_document_id document id of a document to be replaced, if NULL (the default) a new document will be created.
#' @inheritParams api_status
#' @returns Invisible JSON response from the API.
#' @export
document_create_from_html <- function(path, template_id = NULL, folder_id = NULL, tags = NULL, attachments = NULL,
                                      existing_document_id = NULL, api_key = get_api_key()) {
  doc_body <- html_to_doc_body(path, verbose = FALSE)

  if (!is.null(existing_document_id)) {
    template_id <- existing_document_id
  }

  if (!is.null(template_id)) {
    template_fields <- doc_get_fields(template_id)

    if (length(doc_body$fields) != nrow(template_fields)) {
      cli::cli_abort("Document has different number of fields ({length(doc_body$fields)}) than template ({nrow(template_fields)})")
    }
    doc_body$fields <- purrr::map2(doc_body$fields, template_fields$type, ~ {
      if (.y %in% c("string", "date")) {
        .x$content <- rvest::html_text(.x$content)
      } else {
        .x$content <- as.character(.x$content) |> paste(collapse = "\n")
      }
      .x
    })
  } else {
    doc_body$fields <- put_all_fields_in_one_field(doc_body$fields)
  }
  # Add tags, form ID and attachments to doc_body
  doc_body <- add_information_to_doc_body(doc_body, template_id, folder_id, tags, attachments, api_key)

  # Create or replace the document
  if (is.null(existing_document_id)) {
    json <- document_post(doc_body)
  } else {
    json <- document_put(doc_body, existing_document_id)
  }

  return(invisible(json))
}

#' Add html content to an existing RSpace document
#'
#' Append a html document (e.g., generated from quarto) to an RSpace structured document.
#' This function retrieves the current document, and adds text to fields specified by
#' h2 html headers.
#'
#' @param existing_document_id document identifier of the current RSpace document.
#' @param allow_missing_fields Specify if a mismatch in fields is allowed.
#' If this is `FALSE`, the html fields cannot be appended to the RSpace document when fields are missing.
#' If it is `TRUE`, only fields with the same name as in the template will be appended.
#' @inheritParams api_status
#' @inheritParams document_create_from_html
#' @returns Invisible JSON response from the API.
#' @export
document_append_from_html <- function(path, existing_document_id, tags = NULL, attachments = NULL,
                                      allow_missing_fields = FALSE, api_key = get_api_key()) {
  # Get the current fields
  current_fields <- doc_get_fields(existing_document_id)

  # Create a doc_body from the html file and process the fields to be put in a tibble
  doc_body <- html_to_doc_body(path, verbose = FALSE)
  doc_body_types <- current_fields |>
    dplyr::filter(.data$name %in% names(doc_body$fields)) |>
    dplyr::pull(.data$type)

  doc_body$fields <- purrr::map2(doc_body$fields, doc_body_types, ~ {
    if (.y %in% c("string", "date")) {
      .x$content <- rvest::html_text(.x$content)
    } else {
      .x$content <- as.character(.x$content) |> paste(collapse = "\n")
    }
    .x
  })

  # Convert doc_body to a tibble
  new_fields <- fields_to_data_frame(doc_body$fields)

  # Warn users when fields are missing in the html that are present in the existing document
  if (length(setdiff(current_fields$name, new_fields$name)) > 0) {
    if (allow_missing_fields) {
      cli::cli_warn(message = paste0(
        "Some fields are missing in the html to append: ",
        paste0(setdiff(current_fields$name, new_fields$name), collapse = ", "),
        ". Other fields will be added."
      ))
    } else {
      cli::cli_abort(message = paste0("Some fields are missing in the html to append: ",
        paste0(setdiff(current_fields$name, new_fields$name), collapse = ", "),
        ". Specify allow_missing_fields = TRUE if you still want to append the matching fields.",
        collapse = ", "
      ))
    }
  }
  # Warn users when fields are missing in the existing document that are in the html
  if (length(setdiff(new_fields$name, current_fields$name)) > 0) {
    if (allow_missing_fields) {
      cli::cli_warn(message = paste0("The following fields are not in the RSpace document: ",
        paste0(setdiff(new_fields$name, current_fields$name), collapse = ", "),
        ". These will be ignored."
      ))
    } else {
      cli::cli_abort(message = paste0("The following fields are not in the RSpace document: ",
        paste0(setdiff(new_fields$name, current_fields$name), collapse = ", "),
        ". Specify allow_missing_fields = TRUE if you want to ignore these missing fields.",
        collapse = ", "
      ))
    }
  }

  # Merge the old and new fields.
  new_fields <- dplyr::left_join(current_fields, new_fields, by = "name") |>
    dplyr::filter(!is.na(.data$content.y) | .data$content.y != "") |>
    tidyr::unite("content", .data$content.x, .data$content.y, sep = "\n", na.rm = TRUE) |>
    dplyr::mutate(id = as.character(.data$id))

  # Create a nested list with the new contents and identifiers
  doc_body$fields <- data_frame_to_fields(new_fields)

  # Update tags and upload attachments
  doc_body <- add_information_to_doc_body(doc_body, tags = tags,
                                          attachments = attachments,
                                          api_key = api_key)

  # Replace old fields with new fields
  json <- document_put(doc_body, existing_document_id)
  return(json)
}

#' Upload a tabular document to RSpace
#'
#' This function can upload tabular files to RSpace structured documents.
#' The file needs to have exactly two columns, one with the RSpace structured document fields and one with the content.
#'
#' @param path tabular file to upload. Can be XLSX, CSV or TSV
#' @param file_type an optional character string to specify the file type. Will be guessed from the file name if not specified.
#' @param document_name specify the name of the RSpace entry. If not specified,
#' it will be the value in Title, Name, title, or name if that is one of the fields in the Excel document.
#' If that does not exist, it will be the file name.
#' @inheritParams api_status
#' @inheritParams document_create_from_html
#' @returns Invisible JSON response from the API.
#' @export
document_create_from_tabfile <- function(path, file_type = NULL, document_name = NULL, template_id = NULL, folder_id = NULL,
                                       tags = NULL, attachments = NULL, existing_document_id = NULL, api_key = get_api_key()) {
  doc_body <- tabfile_to_doc_body(path, document_name = document_name, verbose = FALSE, file_type = file_type)

  if (!is.null(existing_document_id)) {
    template_id <- existing_document_id
  }
  if (!is.null(template_id)) {
    template_fields <- doc_get_fields(template_id)

    if (length(doc_body$fields) != nrow(template_fields)) {
      cli::cli_abort("Document has different number of fields ({length(doc_body$fields)}) than template ({nrow(template_fields)})")
    }
  } else {
    doc_body$fields <- put_all_fields_in_one_field(doc_body$fields)
  }
  # Add tags, form ID and attachments to doc_body
  doc_body <- add_information_to_doc_body(doc_body, template_id = template_id, folder_id = folder_id, tags = tags, attachments = attachments)

  # Create or replace the document
  if (is.null(existing_document_id)) {
    json <- document_post(doc_body)
  } else {
    json <- document_put(doc_body, existing_document_id)
  }

  return(invisible(json))
}
