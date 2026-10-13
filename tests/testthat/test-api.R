test_that("get_auth_source, get_active_instance, and get_keyring_service defaults and overrides", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    rspacer.auth_source = NULL,
    rspacer.active_instance = NULL,
    rspacer.keyring_service = NULL
  ))
  withr::local_envvar(list(
    RSPACER_AUTH_SOURCE = "",
    RSPACER_ACTIVE_INSTANCE = "",
    RSPACER_KEYRING_SERVICE = ""
  ))

  expect_equal(get_auth_source(), "keyring")
  expect_equal(get_active_instance(), "default")
  expect_equal(get_keyring_service(), "rspacer")

  withr::local_options(list(rspacer.auth_source = "env"))
  expect_equal(get_auth_source(), "env")

  withr::local_options(list(rspacer.active_instance = "leiden"))
  expect_equal(get_active_instance(), "leiden")

  withr::local_options(list(rspacer.keyring_service = "custom_service"))
  expect_equal(get_keyring_service(), "custom_service")

  withr::local_options(list(rspacer.keyring_service = NULL))
  withr::local_envvar(list(RSPACER_KEYRING_SERVICE = "env_service"))
  expect_equal(get_keyring_service(), "env_service")
})

test_that("keyring backend stores and retrieves credentials", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    keyring_backend = "env",
    rspacer.auth_source = "keyring",
    rspacer.active_instance = "default",
    rspacer.keyring_service = "rspacer_test_suite"
  ))

  # Ensure clean starting state and guaranteed cleanup on exit
  unset_api(instance = "default")
  withr::defer(unset_api(instance = "default"))

  # Initially empty -> should error in non-interactive session
  expect_error(get_api_key(), class = "rlang_error")
  expect_error(get_api_url(), class = "rlang_error")

  # Set with value
  set_api_key_with_value("secret_key_123")
  set_api_url_with_value("https://example.com/api/v1")

  expect_equal(get_api_key(), "secret_key_123")
  expect_equal(get_api_url(), "https://example.com/api/v1")

  # Verify only 2 keys exist in keyring (no duplicates)
  keys <- keyring::key_list("rspacer_test_suite")
  expect_equal(sort(keys$username), c("default:api_key", "default:api_url"))

  # get_api returns S3 class rspace_api
  api <- get_api()
  expect_s3_class(api, "rspace_api")
  expect_equal(api$api_key, "secret_key_123")
  expect_equal(api$api_url, "https://example.com/api/v1")
  expect_equal(api$instance, "default")
  expect_equal(api$source, "keyring")

  # print method masks key
  out <- utils::capture.output(print(api))
  expect_true(any(grepl("<RSpace API Credentials>", out)))
  expect_true(any(grepl("Instance:\\s+default \\(source: keyring\\)", out)))
  expect_true(any(grepl("<hidden>", out)))
  expect_false(any(grepl("secret_key_123", out)))

  # reveal_key = TRUE shows key
  out_revealed <- utils::capture.output(print(api, reveal_key = TRUE))
  expect_true(any(grepl("<RSpace API Credentials>", out_revealed)))
  expect_true(any(grepl("Instance:\\s+default \\(source: keyring\\)", out_revealed)))
  expect_true(any(grepl("secret_key_123", out_revealed)))

  # Unset
  unset_api_key()
  expect_error(get_api_key(), class = "rlang_error")
  expect_equal(get_api_url(), "https://example.com/api/v1")

  unset_api_url()
  expect_error(get_api_url(), class = "rlang_error")
})

test_that("set_api and set_api_key error in non-interactive environment without mutating credentials", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    keyring_backend = "env",
    rspacer.keyring_service = "rspacer_test_suite"
  ))

  unset_api()
  expect_error(set_api_key(), "can only be called interactively")
  expect_error(set_api("https://example.com/api/v1"), "can only be called interactively")
  # Verify URL was NOT stored when set_api was rejected
  expect_error(get_api_url(), class = "rlang_error")
})

test_that("multi-instance management with keyring works", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    keyring_backend = "env",
    rspacer.auth_source = "keyring",
    rspacer.keyring_service = "rspacer_test_multi"
  ))

  # Ensure clean starting state and guaranteed cleanup on exit
  unset_api(instance = "default")
  unset_api(instance = "leiden")
  withr::defer({
    unset_api(instance = "default")
    unset_api(instance = "leiden")
  })

  # Configure default instance
  set_api_key_with_value("key_default", instance = "default")
  set_api_url_with_value("https://default.example.com/api/v1", instance = "default")

  # Configure leiden instance
  set_api_key_with_value("key_leiden", instance = "leiden")
  set_api_url_with_value("https://leiden.example.com/api/v1", instance = "leiden")

  # Switch to leiden
  use_instance("leiden")
  expect_equal(get_active_instance(), "leiden")
  expect_equal(get_api_key(), "key_leiden")
  expect_equal(get_api_url(), "https://leiden.example.com/api/v1")

  # Switch back to default
  use_instance("default")
  expect_equal(get_api_key(), "key_default")
  expect_equal(get_api_url(), "https://default.example.com/api/v1")

  # Check list_instances
  inst_df <- list_instances()
  expect_s3_class(inst_df, "tbl_df")
  expect_true(all(c("default", "leiden") %in% inst_df$instance))
  expect_true("source" %in% names(inst_df))
  expect_equal(unique(inst_df$source), "keyring")
  expect_true(inst_df$active[inst_df$instance == "default"])
  expect_false(inst_df$active[inst_df$instance == "leiden"])
  expect_equal(inst_df$api_url[inst_df$instance == "default"], "https://default.example.com/api/v1")
  expect_equal(inst_df$api_url[inst_df$instance == "leiden"], "https://leiden.example.com/api/v1")
  expect_true(inst_df$has_api_key[inst_df$instance == "default"])
  expect_true(inst_df$has_api_key[inst_df$instance == "leiden"])

  # unset_api clears both key and url
  unset_api(instance = "leiden")
  expect_error(get_api_key(instance = "leiden"), class = "rlang_error")
  expect_error(get_api_url(instance = "leiden"), class = "rlang_error")
})

test_that("env var backend works with options and multi-instances", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    rspacer.auth_source = "env",
    rspacer.active_instance = "default"
  ))
  withr::local_envvar(list(
    RSPACE_API_KEY = "",
    RSPACE_API_URL = "",
    RSPACE_DEFAULT_API_KEY = "",
    RSPACE_DEFAULT_API_URL = "",
    RSPACE_LEIDEN_API_KEY = "",
    RSPACE_LEIDEN_API_URL = ""
  ))

  # Missing env vars trigger abort
  expect_error(get_api_key(), "Environment variable .*RSPACE_API_KEY.* is not set")
  expect_error(get_api_url(), "Environment variable .*RSPACE_API_URL.* is not set")

  # Set with value
  set_api_key_with_value("env_key_default")
  set_api_url_with_value("https://env-default.example.com/api/v1")

  expect_equal(get_api_key(), "env_key_default")
  expect_equal(get_api_url(), "https://env-default.example.com/api/v1")

  # Named instance with env vars
  set_api_key_with_value("env_key_leiden", instance = "leiden")
  set_api_url_with_value("https://env-leiden.example.com/api/v1", instance = "leiden")

  expect_equal(get_api_key(instance = "leiden"), "env_key_leiden")
  expect_equal(get_api_url(instance = "leiden"), "https://env-leiden.example.com/api/v1")

  # list_instances with env backend
  inst_df <- list_instances()
  expect_true(all(c("default", "leiden") %in% inst_df$instance))
  expect_true("source" %in% names(inst_df))
  expect_equal(unique(inst_df$source), "env")

  # Unset
  unset_api_key()
  expect_error(get_api_key(), "Environment variable .*RSPACE_API_KEY.* is not set")
})

test_that("api_status returns rspace_api_status object with instance and api_url", {
  local_mocked_bindings(
    req_perform = function(req) {
      httr2::response(
        status_code = 200,
        headers = list("content-type" = "application/json"),
        body = charToRaw('{"message":"OK","rspaceVersion":"1.107.1"}')
      )
    },
    .package = "httr2"
  )

  api <- structure(
    list(
      api_key = "test_key",
      api_url = "https://leiden.researchspace.com/api/v1",
      instance = "leiden",
      source = "keyring"
    ),
    class = c("rspace_api", "list")
  )

  status <- api_status(api = api)
  expect_s3_class(status, "rspace_api_status")
  expect_equal(status$instance, "leiden")
  expect_equal(status$source, "keyring")
  expect_equal(status$api_url, "https://leiden.researchspace.com/api/v1")
  expect_equal(status$message, "OK")
  expect_equal(status$rspaceVersion, "1.107.1")

  out <- utils::capture.output(print(status))
  expect_true(any(grepl("<RSpace API Status>", out)))
  expect_true(any(grepl("Instance:\\s+leiden \\(source: keyring\\)", out)))
  expect_true(any(grepl("https://leiden.researchspace.com/api/v1", out)))
  expect_true(any(grepl("Status Message:\\s+OK", out)))
  expect_true(any(grepl("RSpace Version:\\s+1.107.1", out)))
})

test_that("normalize_instance canonicalizes names and informs about changes", {
  expect_equal(normalize_instance("lab-a"), "lab-a")
  expect_equal(normalize_instance("lab_a"), "lab-a")
  expect_equal(normalize_instance("Lab_A"), "lab-a")
  expect_equal(normalize_instance("  Leiden "), "leiden")
  expect_equal(normalize_instance("default"), "default")

  # No message when the canonical form equals the input or inform = FALSE
  expect_no_message(normalize_instance("lab-a", inform = TRUE))
  expect_no_message(normalize_instance("Lab_A"))
  # Message when canonical form differs from provided name
  expect_message(normalize_instance("Lab_A", inform = TRUE), "normalized to")

  for (bad in c("", " ", "a b", "a:b", "a.b", "1lab", "-a", "a-", "a--b", "a__b", "a_-b", "_a")) {
    expect_error(normalize_instance(bad), class = "rlang_error")
  }
  expect_error(normalize_instance(NA_character_), class = "rlang_error")
  expect_error(normalize_instance(c("a", "b")), class = "rlang_error")
  expect_error(normalize_instance(1), class = "rlang_error")
})

test_that("env var names are unique and reversible for canonical names", {
  expect_equal(env_var_name("default", "api_key"), "RSPACE_API_KEY")
  expect_equal(env_var_name("lab-a", "api_key"), "RSPACE_LAB_A_API_KEY")
  # Spelling variants refer to the same instance (and the same env var)
  expect_equal(env_var_name("lab_a", "api_url"), env_var_name("Lab-A", "api_url"))
  expect_equal(keyring_account_name("Lab_A", "api_key"), "lab-a:api_key")
})

test_that("instance names round-trip through env vars and list_instances", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    rspacer.auth_source = "env",
    rspacer.active_instance = "Lab_A"
  ))
  withr::local_envvar(list(
    RSPACE_API_KEY = "", RSPACE_API_URL = "",
    RSPACE_DEFAULT_API_KEY = "", RSPACE_DEFAULT_API_URL = "",
    RSPACE_LAB_A_API_KEY = "", RSPACE_LAB_A_API_URL = "",
    RSPACE_FOO__BAR_API_KEY = "invalid-foreign-var"
  ))

  # Active instance is canonical
  expect_equal(get_active_instance(), "lab-a")

  # Setting via different spellings writes the same variable
  expect_message(set_api_key_with_value("k1", instance = "lab-a"), "set")
  set_api_url_with_value("https://lab-a.example.com/api/v1", instance = "lab_a")
  expect_equal(Sys.getenv("RSPACE_LAB_A_API_KEY"), "k1")
  expect_equal(get_api_key(instance = "LAB-A"), "k1")

  inst <- list_instances()
  expect_equal(inst$instance, "lab-a")
  expect_equal(inst$source, "env")
  expect_true(inst$active)
  # Foreign / invalid RSPACE_* vars are ignored
  expect_false(any(grepl("foo", inst$instance)))
})

test_that("user is informed when the canonical instance name differs", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    keyring_backend = "env",
    rspacer.auth_source = "keyring",
    rspacer.keyring_service = "rspacer_test_names",
    rspacer.active_instance = NULL
  ))
  withr::defer({
    unset_api(instance = "lab-a")
    unset_api(instance = "default")
  })

  expect_message(use_instance("Lab_A"), "normalized to")
  expect_equal(get_active_instance(), "lab-a")
  # No normalization message when the name is already canonical
  msgs <- testthat::capture_messages(use_instance("lab-a"))
  expect_false(any(grepl("normalized to", msgs)))
})

test_that("keyring deletion errors are propagated and verified absence succeeds silently", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    keyring_backend = "env",
    rspacer.auth_source = "keyring",
    rspacer.active_instance = "default",
    rspacer.keyring_service = "rspacer_test_deletion"
  ))
  withr::defer(unset_api(instance = "default"))

  # 1. Unsetting when no credentials exist succeeds cleanly (verified absent)
  expect_message(unset_api_key(instance = "default"), "unset")

  # 2. Store credentials
  set_api_key_with_value("key_123", instance = "default")
  set_api_url_with_value("https://example.com/api/v1", instance = "default")

  # 3. Simulate backend error during key_delete (e.g. locked keyring)
  local_mocked_bindings(
    key_delete = function(...) stop("Keyring is locked"),
    .package = "keyring"
  )

  # Should abort with rlang_error and describe failure
  expect_error(
    unset_api_key(instance = "default"),
    class = "rlang_error"
  )
  expect_error(
    unset_api_url(instance = "default"),
    class = "rlang_error"
  )

  # 4. Simulate backend error during key_list (e.g. daemon unreachable)
  local_mocked_bindings(
    key_list = function(...) stop("Cannot connect to D-Bus daemon"),
    .package = "keyring"
  )

  expect_error(
    unset_api_key(instance = "default"),
    class = "rlang_error"
  )

  # 5. When keyring file backend returns 'does not exist', treated as empty without error
  local_mocked_bindings(
    key_list = function(...) stop("The 'system' keyring does not exist, create it first!"),
    .package = "keyring"
  )

  expect_message(unset_api_key(instance = "default"), "unset")
})

test_that("rspace_error_body safely extracts messages and handles non-JSON bodies", {
  # JSON with message
  resp_json_msg <- httr2::response(
    status_code = 401,
    headers = list("content-type" = "application/json"),
    body = charToRaw('{"message":"Invalid API key"}')
  )
  expect_equal(rspace_error_body(resp_json_msg), "Invalid API key")

  # JSON with error
  resp_json_err <- httr2::response(
    status_code = 400,
    headers = list("content-type" = "application/json"),
    body = charToRaw('{"error":"Bad Request"}')
  )
  expect_equal(rspace_error_body(resp_json_err), "Bad Request")

  # HTML body (e.g. 404 / 502 page) -> returns NULL without crashing
  resp_html <- httr2::response(
    status_code = 404,
    headers = list("content-type" = "text/html"),
    body = charToRaw('<html><body>Not Found</body></html>')
  )
  expect_null(rspace_error_body(resp_html))

  # Plain text body
  resp_txt <- httr2::response(
    status_code = 500,
    headers = list("content-type" = "text/plain"),
    body = charToRaw('Internal Server Error\n')
  )
  expect_equal(rspace_error_body(resp_txt), "Internal Server Error")

  # No body
  resp_empty <- httr2::response(status_code = 204)
  expect_null(rspace_error_body(resp_empty))

  # Missing content-type header with body -> returns NULL safely (-> falls back to default handler)
  resp_missing_ct <- httr2::response(status_code = 500, body = charToRaw("Internal Error"))
  expect_null(rspace_error_body(resp_missing_ct))

  resp_empty_ct <- httr2::response(
    status_code = 500,
    headers = list("content-type" = ""),
    body = charToRaw("Internal Error")
  )
  expect_null(rspace_error_body(resp_empty_ct))
})

test_that("is_keyring_not_found_msg correctly classifies missing vs operational errors", {
  # Missing entry patterns
  expect_true(is_keyring_not_found_msg("The specified item could not be found in the keychain."))
  expect_true(is_keyring_not_found_msg("Cannot find password"))
  expect_true(is_keyring_not_found_msg("Element not found"))
  expect_true(is_keyring_not_found_msg("No such object"))
  expect_true(is_keyring_not_found_msg("org.freedesktop.Secret.Error.NoSuchObject"))
  expect_true(is_keyring_not_found_msg("The 'system' keyring does not exist"))

  # Operational failures -> must never be treated as not found
  expect_false(is_keyring_not_found_msg("Keyring is locked"))
  expect_false(is_keyring_not_found_msg("Aborted"))
  expect_false(is_keyring_not_found_msg("Cannot connect to D-Bus daemon"))
  expect_false(is_keyring_not_found_msg("The name org.freedesktop.secrets was not provided by any .service files"))
  expect_false(is_keyring_not_found_msg("User interaction is not allowed"))
  expect_false(is_keyring_not_found_msg("Access is denied"))
  expect_false(is_keyring_not_found_msg("Operation not permitted"))
  expect_false(is_keyring_not_found_msg("Authentication failed"))
})

test_that("keyring read operational errors are propagated with cause rather than masked as missing", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    keyring_backend = "env",
    rspacer.auth_source = "keyring",
    rspacer.active_instance = "default",
    rspacer.keyring_service = "rspacer_test_read_errors"
  ))
  withr::defer(unset_api(instance = "default"))

  # Set valid credentials
  set_api_key_with_value("key_123", instance = "default")
  set_api_url_with_value("https://example.com/api/v1", instance = "default")

  # 1. Operational error during key_get (e.g. locked keyring) -> must propagate
  local_mocked_bindings(
    key_get = function(...) stop("Keyring is locked"),
    .package = "keyring"
  )

  err_k <- expect_error(
    get_api_key(instance = "default"),
    class = "rlang_error"
  )
  expect_match(conditionMessage(err_k), "Failed to read credential from keyring")
  expect_match(conditionMessage(err_k), "Keyring is locked")

  err_u <- expect_error(
    get_api_url(instance = "default"),
    class = "rlang_error"
  )
  expect_match(conditionMessage(err_u), "Failed to read credential from keyring")
  expect_match(conditionMessage(err_u), "Keyring is locked")

  # 2. Operational error during key_list (e.g. D-Bus daemon unavailable) -> must propagate
  local_mocked_bindings(
    key_list = function(...) stop("Cannot connect to D-Bus daemon"),
    .package = "keyring"
  )

  err_list <- expect_error(
    get_api_key(instance = "default"),
    class = "rlang_error"
  )
  expect_match(conditionMessage(err_list), "Failed to access keyring service")
  expect_match(conditionMessage(err_list), "Cannot connect to D-Bus daemon")

  err_instances <- expect_error(
    list_instances(),
    class = "rlang_error"
  )
  expect_match(conditionMessage(err_instances), "Failed to access keyring service")
})


