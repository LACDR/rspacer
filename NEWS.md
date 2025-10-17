# rspacer (development version)

# rspacer 0.3.0

* Added support for retrieving paginated results (i.e., more than 20) from the RSpace API endpoints that support it.
* Added `create_document_from_tabular()` function to create RSpace documents directly from R data.frames/tibbles.
* Added `document_get_fields()` function to retrieve the field contents of a given RSpace document.
* `document_list_attachments()` function now returns all attachments instead of just for a given field.
* Fixed: Uploading a document without template id now keeps section headings.
* Simplify return of document search and folder tree functions.
* Add `fields_to_data_frame()` function to convert RSpace document fields to a tibble.
* Update documentation and vignettes.

# rspacer 0.2.0

* Initial release
