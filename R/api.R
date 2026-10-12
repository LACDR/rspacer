# Internal Helpers for Credential Management -----------------------------------

get_auth_source <- function() {
  source <- getOption("rspacer.auth_source")
  if (is.null(source) || identical(source, "")) {
    source <- Sys.getenv("RSPACER_AUTH_SOURCE", "")
  }
  if (is.null(source) || identical(source, "")) {
    source <- "keyring"
  }
  match.arg(source, c("keyring", "env"))
}

get_keyring_service <- function() {
  getOption("rspacer.keyring_service", "rspacer")
}

keyring_account_name <- function(instance, type = c("api_key", "api_url")) {
  type <- match.arg(type)
  paste0(instance, ":", type)
}

env_var_name <- function(instance, type = c("api_key", "api_url")) {
  type <- match.arg(type)
  type_suffix <- if (type == "api_key") "API_KEY" else "API_URL"
  if (identical(instance, "default")) {
    paste0("RSPACE_", type_suffix)
  } else {
    paste0("RSPACE_", toupper(gsub("[^A-Za-z0-9]", "_", instance)), "_", type_suffix)
  }
}

get_keyring_value <- function(service, username) {
  tryCatch(
    keyring::key_get(service = service, username = username),
    error = function(e) NULL
  )
}

# Instance Management ---------------------------------------------------------

#' Get the active RSpace instance name
#'
#' Returns the currently active RSpace instance name.
#'
#' @return A string containing the active instance name (defaults to `"default"`).
#' @export
get_active_instance <- function() {
  inst <- getOption("rspacer.active_instance")
  if (is.null(inst) || identical(inst, "")) {
    inst <- Sys.getenv("RSPACER_ACTIVE_INSTANCE", "")
  }
  if (is.null(inst) || identical(inst, "")) {
    inst <- "default"
  }
  inst
}

#' Set the active RSpace instance
#'
#' Switches the active RSpace instance for the current session.
#'
#' @param instance The instance name as a string (e.g. `"leiden"`, `"bristol"`, or `"default"`).
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @return Invisibly returns the previous active instance name.
#'
#' @examples
#' \dontrun{
#' use_instance("leiden")
#' use_instance("default")
#' }
#' @export
use_instance <- function(instance = "default",
                         source = get_auth_source(),
                         service = get_keyring_service()) {
  if (!is.character(instance) || length(instance) != 1 || identical(trimws(instance), "")) {
    cli::cli_abort("Instance name must be a non-empty character string.")
  }
  instance <- trimws(instance)
  source <- match.arg(source, c("keyring", "env"))
  old_instance <- get_active_instance()
  options(rspacer.active_instance = instance)

  # Check configuration without triggering interactive prompt
  has_url <- FALSE
  has_key <- FALSE
  url_val <- NULL

  if (identical(source, "keyring")) {
    acct_u <- keyring_account_name(instance, "api_url")
    url_val <- get_keyring_value(service, acct_u)
    has_url <- !is.null(url_val) && !identical(url_val, "")

    acct_k <- keyring_account_name(instance, "api_key")
    key_val <- get_keyring_value(service, acct_k)
    has_key <- !is.null(key_val) && !identical(key_val, "")
  } else {
    var_u <- env_var_name(instance, "api_url")
    val_u <- Sys.getenv(var_u)
    if (identical(val_u, "") && identical(instance, "default")) {
      val_u <- Sys.getenv("RSPACE_DEFAULT_API_URL")
    }
    has_url <- !identical(val_u, "")
    url_val <- if (has_url) val_u else NULL

    var_k <- env_var_name(instance, "api_key")
    val_k <- Sys.getenv(var_k)
    if (identical(val_k, "") && identical(instance, "default")) {
      val_k <- Sys.getenv("RSPACE_DEFAULT_API_KEY")
    }
    has_key <- !identical(val_k, "")
  }

  if (has_url && has_key) {
    cli::cli_alert_success("Active RSpace instance switched to {.val {instance}} (URL: {.url {url_val}}).")
  } else {
    cli::cli_alert_info("Active RSpace instance switched to {.val {instance}}.")
    cli::cli_inform(c(
      "i" = "Credentials for {.val {instance}} are not fully configured.",
      "i" = "Run {.run rspacer::set_api()} to configure."
    ))
  }

  invisible(old_instance)
}

#' List configured RSpace instances
#'
#' Lists all RSpace instances configured in the active credential store
#' (system keyring or environment variables).
#'
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @return A tibble with columns `instance`, `active`, `api_url`, and `has_api_key`.
#'
#' @examples
#' \dontrun{
#' list_instances()
#' }
#' @export
list_instances <- function(source = get_auth_source(),
                           service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  active <- get_active_instance()

  if (identical(source, "keyring")) {
    keys <- tryCatch(keyring::key_list(service = service), error = function(e) NULL)
    if (is.null(keys) || nrow(keys) == 0) {
      instances <- character(0)
    } else {
      unames <- keys$username
      instances <- sub(":(api_key|api_url)$", "", unames[grepl(":(api_key|api_url)$", unames)])
      instances <- unique(instances)
    }
  } else {
    env_vars <- names(Sys.getenv())
    rspace_vars <- grep("^RSPACE_", env_vars, value = TRUE)
    instances <- character(0)
    if (any(rspace_vars %in% c("RSPACE_API_KEY", "RSPACE_API_URL", "RSPACE_DEFAULT_API_KEY", "RSPACE_DEFAULT_API_URL"))) {
      instances <- c(instances, "default")
    }
    named_vars <- grep("^RSPACE_[A-Z0-9_]+_API_(KEY|URL)$", rspace_vars, value = TRUE)
    for (v in named_vars) {
      inst <- sub("^RSPACE_", "", v)
      inst <- sub("_API_(KEY|URL)$", "", inst)
      if (!inst %in% c("", "DEFAULT")) {
        instances <- c(instances, tolower(inst))
      }
    }
    instances <- unique(instances)
  }

  if (length(instances) == 0) {
    return(tibble::tibble(
      instance = character(0),
      active = logical(0),
      api_url = character(0),
      has_api_key = logical(0)
    ))
  }

  tibble::tibble(
    instance = instances,
    active = instances == active,
    api_url = purrr::map_chr(instances, function(inst) {
      if (identical(source, "keyring")) {
        u <- get_keyring_value(service, keyring_account_name(inst, "api_url"))
        u %||% NA_character_
      } else {
        u <- Sys.getenv(env_var_name(inst, "api_url"))
        if (identical(u, "") && identical(inst, "default")) {
          u <- Sys.getenv("RSPACE_DEFAULT_API_URL")
        }
        if (identical(u, "")) NA_character_ else u
      }
    }),
    has_api_key = purrr::map_lgl(instances, function(inst) {
      if (identical(source, "keyring")) {
        k <- get_keyring_value(service, keyring_account_name(inst, "api_key"))
        !is.null(k) && !identical(k, "")
      } else {
        k <- Sys.getenv(env_var_name(inst, "api_key"))
        if (identical(k, "") && identical(inst, "default")) {
          k <- Sys.getenv("RSPACE_DEFAULT_API_KEY")
        }
        !identical(k, "")
      }
    })
  )
}

# Credential Setters ----------------------------------------------------------

#' Set RSpace API connection credentials
#'
#' Sets both the API URL and API key for the specified RSpace instance.
#'
#' @param api_url The RSpace API URL string (e.g. `"https://community.researchspace.com/api/v1"`).
#'   If `NULL` and running interactively, prompts the user to enter the URL.
#' @param instance The RSpace instance name (defaults to active instance).
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @examples
#' \dontrun{
#' set_api("https://community.researchspace.com/api/v1")
#' set_api(instance = "leiden")
#' }
#' @export
set_api <- function(api_url = NULL,
                    instance = get_active_instance(),
                    source = get_auth_source(),
                    service = get_keyring_service()) {
  set_api_url(
    api_url = api_url,
    instance = instance,
    source = source,
    service = service
  )
  set_api_key(
    instance = instance,
    source = source,
    service = service
  )
  invisible(TRUE)
}

#' Set the RSpace API key interactively
#'
#' Interactively prompts the user to securely enter their RSpace API key and
#' stores it in the system credential store (keyring) or session environment.
#'
#' By prompting interactively without accepting the key as a function argument,
#' sensitive API tokens will not be recorded in your `.Rhistory` or code scripts.
#' For automated CI environments, use environment variables via `options(rspacer.auth_source = "env")`.
#'
#' @param instance The RSpace instance name (defaults to active instance).
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @examples
#' \dontrun{
#' set_api_key()
#' set_api_key(instance = "leiden")
#' }
#' @export
set_api_key <- function(instance = get_active_instance(),
                        source = get_auth_source(),
                        service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  if (!rlang::is_interactive()) {
    cli::cli_abort(c(
      "{.fun set_api_key} can only be called interactively.",
      "i" = "In automated or CI environments, configure environment variables: {.code options(rspacer.auth_source = \"env\")}"
    ))
  }

  prompt_msg <- paste0("Enter RSpace API key for instance '", instance, "': ")
  if (identical(source, "keyring")) {
    acct <- keyring_account_name(instance, "api_key")
    keyring::key_set(service = service, username = acct, prompt = prompt_msg)
    cli::cli_alert_success("RSpace API key stored in system keyring for instance {.val {instance}}.")
  } else {
    key <- askpass::askpass(prompt = prompt_msg)
    if (is.null(key) || identical(key, "")) {
      cli::cli_abort("No API key entered.")
    }
    var_name <- env_var_name(instance, "api_key")
    do.call(Sys.setenv, stats::setNames(list(key), var_name))
    cli::cli_alert_success("Environment variable {.envvar {var_name}} set for session.")
  }
  invisible(TRUE)
}

#' Set the RSpace API key programmatically
#' @noRd
set_api_key_with_value <- function(api_key,
                                   instance = get_active_instance(),
                                   source = get_auth_source(),
                                   service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  if (missing(api_key) || !is.character(api_key) || length(api_key) != 1 || identical(api_key, "")) {
    cli::cli_abort("Please provide a non-empty character string for {.arg api_key}.")
  }

  if (identical(source, "keyring")) {
    acct <- keyring_account_name(instance, "api_key")
    keyring::key_set_with_value(service = service, username = acct, password = api_key)
    cli::cli_alert_success("RSpace API key stored in system keyring for instance {.val {instance}}.")
  } else {
    var_name <- env_var_name(instance, "api_key")
    do.call(Sys.setenv, stats::setNames(list(api_key), var_name))
    cli::cli_alert_success("Environment variable {.envvar {var_name}} set.")
  }
  invisible(TRUE)
}

#' Set the RSpace API URL
#'
#' Sets the RSpace API URL for the specified instance. If `api_url` is `NULL` and
#' running interactively, prompts the user to enter the URL.
#'
#' @param api_url The RSpace API URL (e.g. `"https://community.researchspace.com/api/v1"`).
#'   If `NULL` and interactive, prompts the user.
#' @param instance The RSpace instance name (defaults to active instance).
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @examples
#' \dontrun{
#' set_api_url("https://community.researchspace.com/api/v1")
#' set_api_url(instance = "leiden")
#' }
#' @export
set_api_url <- function(api_url = NULL,
                        instance = get_active_instance(),
                        source = get_auth_source(),
                        service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  if (is.null(api_url)) {
    if (!rlang::is_interactive()) {
      cli::cli_abort(c(
        "Argument {.arg api_url} must be provided when running non-interactively.",
        "i" = "Example: {.run rspacer::set_api_url(\"https://community.researchspace.com/api/v1\")}"
      ))
    }
    api_url <- readline(paste0("Enter RSpace API URL for instance '", instance, "': "))
    if (identical(trimws(api_url), "")) {
      cli::cli_abort("No API URL entered.")
    }
  }

  set_api_url_with_value(
    api_url = api_url,
    instance = instance,
    source = source,
    service = service
  )
}

#' Set the RSpace API URL programmatically
#' @noRd
set_api_url_with_value <- function(api_url,
                                   instance = get_active_instance(),
                                   source = get_auth_source(),
                                   service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  if (missing(api_url) || !is.character(api_url) || length(api_url) != 1 || identical(trimws(api_url), "")) {
    cli::cli_abort("Please provide a valid character string for {.arg api_url}.")
  }
  api_url <- trimws(api_url)

  if (identical(source, "keyring")) {
    acct <- keyring_account_name(instance, "api_url")
    keyring::key_set_with_value(service = service, username = acct, password = api_url)
    cli::cli_alert_success("RSpace API URL stored in system keyring for instance {.val {instance}}.")
  } else {
    var_name <- env_var_name(instance, "api_url")
    do.call(Sys.setenv, stats::setNames(list(api_url), var_name))
    cli::cli_alert_success("Environment variable {.envvar {var_name}} set.")
  }
  invisible(TRUE)
}

# Credential Unsetters --------------------------------------------------------

#' Unset RSpace API credentials
#'
#' Removes stored credentials from the system keyring or current session environment.
#'
#' @param instance The RSpace instance name (defaults to active instance).
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @examples
#' \dontrun{
#' unset_api_key()
#' unset_api_url()
#' unset_api()
#' }
#' @name unset_credentials
#' @export
unset_api_key <- function(instance = get_active_instance(),
                          source = get_auth_source(),
                          service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  if (identical(source, "keyring")) {
    acct <- keyring_account_name(instance, "api_key")
    tryCatch(keyring::key_delete(service = service, username = acct), error = function(e) NULL)
    cli::cli_alert_success("RSpace API key unset from system keyring for instance {.val {instance}}.")
  } else {
    var_name <- env_var_name(instance, "api_key")
    Sys.unsetenv(var_name)
    if (identical(instance, "default")) {
      Sys.unsetenv("RSPACE_API_KEY")
      Sys.unsetenv("RSPACE_DEFAULT_API_KEY")
    }
    cli::cli_alert_success("Environment variable {.envvar {var_name}} unset.")
  }
  invisible(TRUE)
}

#' @rdname unset_credentials
#' @export
unset_api_url <- function(instance = get_active_instance(),
                          source = get_auth_source(),
                          service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  if (identical(source, "keyring")) {
    acct <- keyring_account_name(instance, "api_url")
    tryCatch(keyring::key_delete(service = service, username = acct), error = function(e) NULL)
    cli::cli_alert_success("RSpace API URL unset from system keyring for instance {.val {instance}}.")
  } else {
    var_name <- env_var_name(instance, "api_url")
    Sys.unsetenv(var_name)
    if (identical(instance, "default")) {
      Sys.unsetenv("RSPACE_API_URL")
      Sys.unsetenv("RSPACE_DEFAULT_API_URL")
    }
    cli::cli_alert_success("Environment variable {.envvar {var_name}} unset.")
  }
  invisible(TRUE)
}

#' @rdname unset_credentials
#' @export
unset_api <- function(instance = get_active_instance(),
                      source = get_auth_source(),
                      service = get_keyring_service()) {
  unset_api_key(instance = instance, source = source, service = service)
  unset_api_url(instance = instance, source = source, service = service)
  invisible(TRUE)
}

# Credential Getters ----------------------------------------------------------

#' Get the RSpace API key
#'
#' Retrieves the RSpace API key for the specified instance from the system keyring
#' or environment variables. If no key is found in an interactive session, offers
#' to prompt and store it immediately.
#'
#' @param instance The RSpace instance name (defaults to active instance).
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @return The RSpace API key string.
#' @noRd
get_api_key <- function(instance = get_active_instance(),
                        source = get_auth_source(),
                        service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  api_key <- NULL

  if (identical(source, "keyring")) {
    acct <- keyring_account_name(instance, "api_key")
    api_key <- get_keyring_value(service, acct)
  } else {
    var_name <- env_var_name(instance, "api_key")
    val <- Sys.getenv(var_name)
    if (!identical(val, "")) {
      api_key <- val
    } else if (identical(instance, "default")) {
      val_def <- Sys.getenv("RSPACE_DEFAULT_API_KEY")
      if (!identical(val_def, "")) {
        api_key <- val_def
      }
    }
  }

  if (is.null(api_key) || identical(api_key, "")) {
    if (rlang::is_interactive()) {
      cli::cli_alert_warning("No RSpace API key found for instance {.val {instance}} (source: {.val {source}}).")
      if (ui_yes("Would you like to enter an API key now?")) {
        set_api_key(instance = instance, source = source, service = service)
        return(get_api_key(instance = instance, source = source, service = service))
      }
    }

    if (identical(source, "keyring")) {
      cli::cli_abort(c(
        "RSpace API key not found in system keyring for instance {.val {instance}}.",
        "i" = "Run {.run rspacer::set_api_key(instance = \"{instance}\")} to store your API key.",
        "i" = "To read from environment variables instead, set {.code options(rspacer.auth_source = \"env\")}."
      ))
    } else {
      var_name <- env_var_name(instance, "api_key")
      cli::cli_abort(c(
        "Environment variable {.envvar {var_name}} is not set.",
        "i" = "Set it in your {.file .Renviron} file or run {.run rspacer::set_api_key(instance = \"{instance}\")}."
      ))
    }
  }

  api_key
}

#' Get the RSpace API URL
#'
#' Retrieves the RSpace API URL for the specified instance from the system keyring
#' or environment variables. If no URL is found in an interactive session, offers
#' to prompt and store it immediately.
#'
#' @param instance The RSpace instance name (defaults to active instance).
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @return The RSpace API URL string.
#' @noRd
get_api_url <- function(instance = get_active_instance(),
                        source = get_auth_source(),
                        service = get_keyring_service()) {
  source <- match.arg(source, c("keyring", "env"))
  api_url <- NULL

  if (identical(source, "keyring")) {
    acct <- keyring_account_name(instance, "api_url")
    api_url <- get_keyring_value(service, acct)
  } else {
    var_name <- env_var_name(instance, "api_url")
    val <- Sys.getenv(var_name)
    if (!identical(val, "")) {
      api_url <- val
    } else if (identical(instance, "default")) {
      val_def <- Sys.getenv("RSPACE_DEFAULT_API_URL")
      if (!identical(val_def, "")) {
        api_url <- val_def
      }
    }
  }

  if (is.null(api_url) || identical(api_url, "")) {
    if (rlang::is_interactive()) {
      cli::cli_alert_warning("No RSpace API URL found for instance {.val {instance}} (source: {.val {source}}).")
      if (ui_yes("Would you like to enter an API URL now?")) {
        set_api_url(instance = instance, source = source, service = service)
        return(get_api_url(instance = instance, source = source, service = service))
      }
    }

    if (identical(source, "keyring")) {
      cli::cli_abort(c(
        "RSpace API URL not found in system keyring for instance {.val {instance}}.",
        "i" = "Run {.run rspacer::set_api_url(instance = \"{instance}\")} to store your API URL.",
        "i" = "To read from environment variables instead, set {.code options(rspacer.auth_source = \"env\")}."
      ))
    } else {
      var_name <- env_var_name(instance, "api_url")
      cli::cli_abort(c(
        "Environment variable {.envvar {var_name}} is not set.",
        "i" = "Set it in your {.file .Renviron} file or run {.run rspacer::set_api_url(instance = \"{instance}\")}."
      ))
    }
  }

  api_url
}

#' Get the RSpace API connection
#'
#' Retrieves the API URL, API key, and instance name as an `rspace_api` object.
#'
#' By default, printing this object in the console hides the sensitive API key.
#'
#' @param instance The RSpace instance name (defaults to active instance).
#' @param source Credential source: `"keyring"` (default) or `"env"`.
#' @param service Keyring service name (defaults to `"rspacer"`).
#'
#' @return An S3 object of class `rspace_api` (inheriting from `list`) containing
#'   `api_key`, `api_url`, and `instance`.
#'
#' @examples
#' \dontrun{
#' get_api()
#' get_api(instance = "leiden")
#' }
#' @export
get_api <- function(instance = get_active_instance(),
                    source = get_auth_source(),
                    service = get_keyring_service()) {
  structure(
    list(
      instance = instance,
      api_url = get_api_url(instance = instance, source = source, service = service),
      api_key = get_api_key(instance = instance, source = source, service = service)
    ),
    class = c("rspace_api", "list")
  )
}

#' Print method for RSpace API connection
#'
#' Displays the RSpace API connection information while masking the API key by default.
#'
#' @param x An `rspace_api` object returned by [get_api()].
#' @param ... Additional arguments passed to print methods.
#' @param reveal_key Logical; if `TRUE`, reveals the full API key. Defaults to `FALSE`.
#'
#' @export
print.rspace_api <- function(x, ..., reveal_key = FALSE) {
  key_display <- if (isTRUE(reveal_key)) {
    x$api_key
  } else {
    "<hidden>"
  }

  inst_name <- x$instance %||% "default"
  cat("<RSpace API connection>\n")
  cat(paste0("  * Instance: ", inst_name, "\n"))
  cat(paste0("  * API URL:  ", x$api_url, "\n"))
  cat(paste0("  * API Key:  ", key_display, "\n"))
  invisible(x)
}

# Request & Communication -----------------------------------------------------

rspace_error_body <- function(resp) {
  resp |>
    httr2::resp_body_json() |>
    purrr::pluck("message")
}

create_global_id_link <- function(global_id, api = get_api()) {
  # TODO: wait for https://github.com/r-lib/httr2/issues/464
  # for this function to be exported in httr2
  httr2::url_modify(api$api_url, path = glue::glue("globalId/{global_id}"))
}

request <- function(api = get_api()) {
  httr2::request(api$api_url) |>
    httr2::req_user_agent("rspacer (https://github.com/burgerga/rspacer)") |>
    httr2::req_headers(`apiKey` = api$api_key) |>
    httr2::req_error(body = rspace_error_body)
}

#' Function to check availability of the API service
#'
#' Queries the status endpoint of the RSpace API service and returns
#' connection and server status information.
#'
#' @param api RSpace API connection object returned by [get_api()] (defaults to `get_api()`).
#'
#' @return An S3 object of class `rspace_api_status` (inheriting from `list`) containing
#'   `instance`, `api_url`, `message`, `rspaceVersion`, and any additional status response fields.
#'
#' @examples
#' \dontrun{
#' api_status()
#' }
#' @export
api_status <- function(api = get_api()) {
  resp <- request(api) |>
    httr2::req_url_path_append("status") |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  res <- c(
    list(
      instance = api$instance %||% "default",
      api_url = api$api_url
    ),
    resp
  )
  structure(res, class = c("rspace_api_status", "list"))
}

#' Print method for RSpace API status
#'
#' Displays RSpace API status information including the instance name and URL.
#'
#' @param x An `rspace_api_status` object returned by [api_status()].
#' @param ... Additional arguments passed to print methods.
#'
#' @export
print.rspace_api_status <- function(x, ...) {
  inst_name <- x$instance %||% "default"
  cat("<RSpace API status>\n")
  cat(paste0("  * Instance:       ", inst_name, "\n"))
  cat(paste0("  * API URL:        ", x$api_url, "\n"))
  if (!is.null(x$message)) {
    cat(paste0("  * Status Message: ", x$message, "\n"))
  }
  if (!is.null(x$rspaceVersion)) {
    cat(paste0("  * RSpace Version: ", x$rspaceVersion, "\n"))
  }
  other_fields <- setdiff(names(x), c("instance", "api_url", "message", "rspaceVersion"))
  for (f in other_fields) {
    cat(paste0("  * ", f, ": ", x[[f]], "\n"))
  }
  invisible(x)
}

