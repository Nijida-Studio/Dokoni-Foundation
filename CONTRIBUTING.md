# Contributing to Dokoni Foundation

Dokoni Foundation follows ODTS 1.9.5 and a documentation- and test-oriented
SwiftPM workflow.

## Before implementation

1. Create or select an ODTS Epic.
2. Create an ODTS Item with exactly one parent Epic.
3. Create an ODTS Task with exactly one parent Item.
4. Preserve the visible ODTS Version supplied by the Issue Form.
5. Read the Epic, Item, Task, module README, architecture, and developer guide.
6. Create the source skeleton and public signatures.
7. Add rudimentary DocC comments.
8. Add tests for intended behavior where technically possible.
9. Review that foundation before adding complete logic.

## Source traceability

Add the implementing Task URL at the beginning of every materially changed
source and test file:

~~~swift
// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4
~~~

Follow the complete convention in
[ODTS Traceability](docs/ODTSTraceability.md).

## Documentation quality

Public APIs require DocC-compatible comments that describe contracts rather
than restating names. Include parameters, returns, errors, cleanup, lifetime,
concurrency, and examples where relevant.

Update both:

- the target's DocC catalog for module-specific documentation;
- docs/DeveloperGuide.md for cross-module behavior.

## Validation

Run:

~~~sh
swift build
swift test
~~~

Generate symbol graphs and render DocC with the available Apple toolchain.
Treat unresolved symbol links and documentation warnings as failures unless the
Task records a justified toolchain limitation.

## Pull requests

Use .github/pull_request_template.md, link the Task and parent Item, record
validation, and list deferred work as separate ODTS Tasks.
