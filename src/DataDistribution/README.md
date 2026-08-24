# DataDistribution

DataDistribution is the Foundation module for distributing settings and user
data beyond one local installation.

## Responsibility

- synchronize data for one user across that user's devices,
- use providers such as iCloud for distribution,
- share explicitly with another person,
- support explicitly defined family sharing,
- model ownership, permissions, revocation, conflicts, and provenance.

Device synchronization, sharing with another person, and family sharing are
distinct authorization and privacy cases. The module must not treat them as
equivalent or enable sharing implicitly.

DataDistribution may use Settings for configuration, ResourceAccess for
managed sources, and DataStorage for storage operations.

No `Sources/` directory exists yet because the public contract remains
undefined. Source groups and targets are added only after data ownership,
encryption, conflict, consent, and consumer requirements are documented.

The detailed admission checklist and dependency boundary are recorded in
[DataDistribution Developer Boundary](../../docs/DataDistribution.md).
