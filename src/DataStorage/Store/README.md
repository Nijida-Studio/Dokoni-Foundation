# DataStorage Store

The first storage operation is implemented by
`../Sources/DataStorageReader.swift`.

Further byte, document, key-value, or relational operations may be added when a
concrete consumer requires them. Resource connections remain owned by
ResourceAccess, and storage operations do not interpret application semantics.
