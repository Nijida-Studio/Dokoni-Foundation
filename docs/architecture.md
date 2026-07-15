# Architecture

## Role in the Dokoni ecosystem

Dokoni Foundation is the shared technical library layer of the Dokoni
ecosystem. It sits below applications and their user interfaces:

```text
Platform-specific user interfaces
        SwiftUI / Avalonia / others
                    |
Application-specific libraries and workflows
        Kizuna / Akari CE / Souran / others
                    |
Dokoni Foundation shared capabilities
        Core services / GitHub / future modules
                    |
General-purpose platform and third-party libraries
```

Dokoni itself is the central application of the ecosystem, but Foundation is
not part of Dokoni's user interface or application-specific core. Foundation
libraries must remain consumable by other ecosystem applications independently.

## Ownership boundaries

### Foundation owns

- reusable capabilities required by multiple ecosystem applications,
- UI-independent contracts and implementations,
- cross-application semantics, test fixtures, and compatibility guidance,
- integrations whose reusable portion is not tied to one application's
  workflow.

### Applications own

- platform-specific presentation and interaction,
- application workflows and product decisions,
- libraries used by only that application,
- adapters that translate Foundation capabilities into application behavior.

### External dependencies own

- general-purpose functionality that is not specific to the Dokoni ecosystem,
- platform SDKs and established third-party protocols or clients.

Foundation may wrap an external dependency behind a stable ecosystem contract
when multiple applications require the same behavior. It should not duplicate
an external library merely to place it under the Dokoni name.

## Platform model

Swift and .NET implementations are organized separately under `src/`. They do
not depend on SwiftUI or Avalonia. A capability does not need byte-for-byte
identical implementations on every platform, but its observable behavior,
terminology, and compatibility expectations should be documented consistently.

When a capability exists on more than one platform, its module documentation
should define:

- responsibility and non-goals,
- public concepts and behavior,
- error and cancellation semantics,
- data ownership and privacy expectations,
- platform-specific deviations,
- compatibility and versioning expectations.

## Dependency direction

Applications may depend on Foundation modules. Foundation modules must not
depend on an application or its UI layer. Shared integration modules may depend
on smaller Foundation modules, but dependency cycles between modules are not
allowed.

## Module lifecycle

1. Record at least two intended consumers.
2. Define the capability boundary and public contract.
3. Select the required platform implementation or implementations.
4. Add tests before or alongside the implementation where technically
   possible.
5. Version and release modules so applications can update deliberately.

Moving an existing app-specific library into Foundation requires an explicit
contract review. Source code should not be copied merely because a second
consumer appears.
