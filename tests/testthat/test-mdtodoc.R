test_that("add_information_to_doc_body can add information to a list", {
  # nothing added
  expect_equal(add_information_to_doc_body(list()), list())
  # template_id
  expect_error(add_information_to_doc_body(list(), template_id = "incorrect ID"))
  # TODO below how to check a correct but non-existing template and think about the attachments
  # expect_error(add_information_to_doc_body(list(), template_id = "SD001"))
  # expect_equal(add_information_to_doc_body(list(), folder_id = "SD123", tags = "test", attachment = list("7" = "hoi.txt")))

  expect_equal(
    add_information_to_doc_body(list(), folder_id = "SD123", tags = "test"),
    list(parentFolderId = 123, tags = "test")
  )
})

test_that("create_rspace_document_name can process a document name", {
  sections <- helper_get_sections()
  # Check document name
  expect_equal(create_rspace_document_name(
    df = NULL, document_name = "thisone"
  ), "thisone")
  # document_name should be character string
  expect_error(create_rspace_document_name(df = NULL, document_name = NA))
  expect_error(create_rspace_document_name(df = NULL, document_name = 123))
  # Check to get name from sections in the order that is in the user manual
  expect_equal(create_rspace_document_name(
    df = sections, document_name = "thisone"
  ), "thisone")
  expect_equal(create_rspace_document_name(df = sections), "The title")
  expect_equal(create_rspace_document_name(df = sections[2:6, ]), "test")
  expect_equal(create_rspace_document_name(df = sections[3:6, ]), "small title")
  expect_equal(create_rspace_document_name(df = sections[4:6, ]), "smaller name")
  # No name in secions, return NULL
  expect_equal(
    create_rspace_document_name(df = sections[5:6, ]),
    NULL
  )
})

test_that("tabfile_to_df can create a df", {
  # these should work
  expect_true(is.data.frame(tabfile_to_df(path = testthat::test_path("minimal_excel.xlsx"), file_type = "xlsx")))
  expect_true(is.data.frame(tabfile_to_df(path = testthat::test_path("minimal_csv1.csv"), file_type = "csv")))
  expect_true(is.data.frame(tabfile_to_df(path = testthat::test_path("minimal_tsv.txt"), file_type = "tsv")))
  # guess file format. should also work
  expect_true(is.data.frame(tabfile_to_df(path = testthat::test_path("minimal_excel.xlsx"))))
  expect_true(is.data.frame(tabfile_to_df(path = testthat::test_path("minimal_csv1.csv"))))
  # this one should be too hard to guess because tsv file saved as .txt without specifying that it is tab-separated.
  expect_error(tabfile_to_df(path = testthat::test_path("minimal_tsv.txt")))
  # test verbose
  expect_true(is.data.frame(tabfile_to_df(path = testthat::test_path("minimal_excel.xlsx"), file_type = "xlsx")))
  # not existing file
  expect_error(tabfile_to_df(path = "not_existing_file.xlsx", file_type = ".xlsx"))
  # incorrect excel file type specified
  expect_error(tabfile_to_df(path = testthat::test_path("minimal_excel.xlsx"), file_type = ".xlsx"))
})
