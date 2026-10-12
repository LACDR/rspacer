# rspacer (development version)

* **Credential Security & Keyring**: Credentials (API URL and API Key) are now securely stored and encrypted in the OS credential manager via `keyring` by default.
* Added `set_api()` to configure both API URL and API Key in a single command.
* `set_api_key()` now prompts interactively with masked input to prevent credentials from being recorded in `.Rhistory`.
* Added `unset_api_key()`, `unset_api_url()`, and `unset_api()` to remove stored credentials.
* **Multi-Instance Support**: Easily configure and switch between multiple RSpace deployments using `use_instance()`, `list_instances()`, and the `instance` argument on all credential functions.
* **Masked API Key Output**: `get_api()` now returns an `rspace_api` S3 object whose `print()` method masks the API key by default (`<hidden>`), preventing accidental leakage in console outputs, knitted documents, or logs.
* **Enhanced `api_status()`**: Now returns an `rspace_api_status` S3 object displaying the active instance, API URL, status message, and server version.
* **Environment Variable Compatibility**: Retained full compatibility with environment variables via `options(rspacer.auth_source = "env")` or `RSPACER_AUTH_SOURCE="env"`.

# rspacer 0.1.0

* Initial release
