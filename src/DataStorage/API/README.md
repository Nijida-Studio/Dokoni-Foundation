# DataStorage API

The first concrete API is implemented in `../Sources/`.

`DataStorageReader` reads a `ReadableByteConnection` into a caller-supplied
`DataStreamReceiver`. Later APIs may add writing, replacement, SQL operations,
and structured streams without defining application data formats.
