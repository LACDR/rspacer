# rspacer (development version)

* **Credential Security & Keyring**: Credentials (API URL and API Key) are now securely stored and encrypted in the OS credential manager via `keyring` by default.
* Added `set_api()` to configure both API URL and API Key in a single command.
* `set_api_key()` now prompts interactively with masked input to prevent credentials from being recorded in `.Rhistory`.
* Added `unset_api_key()`, `unset_api_url()`, and `unset_api()` to remove stored credentials.
* **Multi-Instance Support**: Easily configure and switch between multiple RSpace deployments using `use_instance()`, `list_instances()`, and the `instance` argument on all credential functions. Instance names are case-insensitive and `_` is treated as `-` (canonical form: lowercase with `-`, e.g. `"Lab_A"` becomes `"lab-a"`), so names map unambiguously to environment variables (`RSPACE_LAB_A_API_KEY`). You are informed when the canonical name differs from the name you provided.
* **Masked API Key Output**: `get_api()` now returns an `rspace_api` S3 object whose `print()` method masks the API key by default (`<hidden>`), preventing accidental leakage in console outputs, knitted documents, or logs.
* **Enhanced `api_status()`**: Now returns an `rspace_api_status` S3 object displaying the active instance, API URL, status message, and server version.
* **Environment Variable Compatibility**: Retained full compatibility with environment variables via `options(rspacer.auth_source = "env")` or `RSPACER_AUTH_SOURCE="env"`.

# rspacer 0.3.1

* Documentation improvements.
* Fix `httr2` dependency version issue.

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
