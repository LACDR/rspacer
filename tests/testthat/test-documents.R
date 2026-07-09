test_that("document_list_attachments", {
  local_mocked_bindings(
    get_api = function() {
      return(list(api_key = "API key used for testing", api_url = "https://example.com/api/v1"))
    },
    document_get_fields = function(doc_id, api = get_api()) {
      helper_get_fields_df()
    }
  )

  # Should have no attachments
  expect_equal(nrow(document_list_attachments("123") |> dplyr::filter(field_id == 1)), 0)

  # Should return a tibble created with two attachments: 2 rows, 9 columns.
  expect_type(document_list_attachments("ABC"), typeof(tibble::tibble()))
  expect_equal(nrow(document_list_attachments("ABC")), 2)
  expect_equal(nrow(document_list_attachments("ABC") |> dplyr::filter(field_name == "results")), 2)
  expect_equal(nrow(document_list_attachments("ABC") |> dplyr::filter(field_id == 4)), 2)

  # Error if input is incorrect
  expect_error(document_list_attachments())
})
