# DataStorage

DataStorage reads and writes opaque data without knowing its format.

## Initial structure

- `Models/` contains storage identifiers, locations, and storage errors.
- `Store/` contains concrete storage implementations.
- `API/` contains the interface used to read and write data.

A consuming module decodes, modifies, and encodes the content. DataStorage only
reads it and writes the resulting data back. Platform-specific storage is added
later behind the same API.
