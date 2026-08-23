# LocalSettings

LocalSettings manages settings that belong to one local installation.

## Initial structure

- `Models/` contains the settings data owned by this module.
- `Store/` reads, modifies, and manages settings.
- `API/` contains the interface used by other modules to query or change settings.

LocalSettings owns the settings format. It uses DataStorage to read opaque data
and write the encoded result back to its storage location.

Credentials and secrets are not ordinary settings. Synchronization or sharing
belongs to DataDistribution.

The first implementation will use platform-neutral Swift and then add the
required Apple-specific Swift parts. Further structure is added only when the
implementation needs it.
