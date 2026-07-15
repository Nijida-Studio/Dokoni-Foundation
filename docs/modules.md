# Module Catalog

This catalog records shared capabilities before concrete package names and APIs
are finalized.

## Foundation capabilities

**Status:** Planned

**Initial consumers:** Kizuna, Akari CE

This area will contain the smallest common technical building blocks that are
actually required by both applications. No specific logging, configuration,
localization, serialization, or dependency-injection API is accepted merely by
being generally useful; each capability must have a demonstrated multi-app need
before implementation.

## GitHub capability

**Status:** Planned

**Initial consumers:** Kizuna, Souran

The reusable GitHub layer belongs in Foundation because both applications need
access to GitHub. It should own provider-level concepts and operations that are
independent of either application's workflow.

Kizuna continues to own synchronization between GitHub and personal
productivity systems. Souran will own its SCM and DevOps workflows. Foundation
must not absorb those product-specific responsibilities.

The first contract definition should decide:

- authentication abstraction and credential ownership,
- repository and issue identifiers,
- read, create, and update operations,
- pagination, rate-limit, error, and cancellation behavior,
- test doubles and safe integration-test boundaries,
- which behavior is required in Swift and .NET.

## Candidate capabilities

Future candidates such as Git, OAuth, settings, localization, serialization,
notifications, or Markdown remain unaccepted until at least two concrete
consumers and a UI-independent boundary have been identified.
