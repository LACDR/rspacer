test_that("get_auth_source and get_active_instance default and option overrides", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    rspacer.auth_source = NULL,
    rspacer.active_instance = NULL
  ))
  withr::local_envvar(list(
    RSPACER_AUTH_SOURCE = "",
    RSPACER_ACTIVE_INSTANCE = ""
  ))

  expect_equal(get_auth_source(), "keyring")
  expect_equal(get_active_instance(), "default")

  withr::local_options(list(rspacer.auth_source = "env"))
  expect_equal(get_auth_source(), "env")

  withr::local_options(list(rspacer.active_instance = "leiden"))
  expect_equal(get_active_instance(), "leiden")
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
  unset_api(instance = "default", service = "rspacer_test_suite")
  withr::defer(unset_api(instance = "default", service = "rspacer_test_suite"))

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

  # print method masks key
  out <- utils::capture.output(print(api))
  expect_true(any(grepl("<hidden>", out)))
  expect_false(any(grepl("secret_key_123", out)))

  # reveal_key = TRUE shows key
  out_revealed <- utils::capture.output(print(api, reveal_key = TRUE))
  expect_true(any(grepl("secret_key_123", out_revealed)))

  # Unset
  unset_api_key()
  expect_error(get_api_key(), class = "rlang_error")
  expect_equal(get_api_url(), "https://example.com/api/v1")

  unset_api_url()
  expect_error(get_api_url(), class = "rlang_error")
})

test_that("set_api and set_api_key error in non-interactive environment", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    keyring_backend = "env",
    rspacer.keyring_service = "rspacer_test_suite"
  ))

  expect_error(set_api_key(), "can only be called interactively")
  expect_error(set_api("https://example.com/api/v1"), "can only be called interactively")
})

test_that("multi-instance management with keyring works", {
  rlang::local_interactive(FALSE)
  withr::local_options(list(
    keyring_backend = "env",
    rspacer.auth_source = "keyring",
    rspacer.keyring_service = "rspacer_test_multi"
  ))

  # Ensure clean starting state and guaranteed cleanup on exit
  unset_api(instance = "default", service = "rspacer_test_multi")
  unset_api(instance = "leiden", service = "rspacer_test_multi")
  withr::defer({
    unset_api(instance = "default", service = "rspacer_test_multi")
    unset_api(instance = "leiden", service = "rspacer_test_multi")
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
  expect_true(inst_df$active[inst_df$instance == "default"])
  expect_false(inst_df$active[inst_df$instance == "leiden"])

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
      instance = "leiden"
    ),
    class = c("rspace_api", "list")
  )

  status <- api_status(api = api)
  expect_s3_class(status, "rspace_api_status")
  expect_equal(status$instance, "leiden")
  expect_equal(status$api_url, "https://leiden.researchspace.com/api/v1")
  expect_equal(status$message, "OK")
  expect_equal(status$rspaceVersion, "1.107.1")

  out <- utils::capture.output(print(status))
  expect_true(any(grepl("<RSpace API status>", out)))
  expect_true(any(grepl("Instance:\\s+leiden", out)))
  expect_true(any(grepl("https://leiden.researchspace.com/api/v1", out)))
  expect_true(any(grepl("Status Message:\\s+OK", out)))
  expect_true(any(grepl("RSpace Version:\\s+1.107.1", out)))
})
