# Dokoni Foundation

Dokoni Foundation contains reusable, user-interface-independent libraries for
applications in the Dokoni ecosystem.

The repository is the shared technical layer between applications. It does not
contain SwiftUI, Avalonia, or other platform-specific user interfaces, and it is
not a home for libraries used by only one application.

## Initial consumers

- **Kizuna** and **Akari CE** are the first applications expected to consume
  common Foundation libraries.
- A shared GitHub capability is intended for **Kizuna** and the future
  **Souran** project.

## Repository structure

```text
docs/
  architecture.md       Stable boundaries and dependency rules
  modules.md            Planned and accepted shared capabilities
src/
  dotnet/               .NET implementations, independent of Avalonia
  swift/                Swift implementations, independent of SwiftUI
```

Concrete packages will be added only after their responsibilities and public
contracts have been defined. Platform implementations may differ internally,
but equivalent capabilities should follow the same documented semantics where
that is practical.

## Module admission rule

A library belongs in Dokoni Foundation when at least two Dokoni ecosystem
applications need the capability and the capability can remain independent of
their user interfaces and application-specific workflows.

Libraries needed by only one application stay in that application's
repository. General-purpose third-party libraries remain external dependencies
rather than being copied into this repository.

## Documentation and website

- Architecture: [`docs/architecture.md`](docs/architecture.md)
- Module catalog: [`docs/modules.md`](docs/modules.md)
- Project website: <https://foundation.nijida.de>

Maintained source and project documentation live on `main`. The website is
maintained separately on `gh_pages`.
