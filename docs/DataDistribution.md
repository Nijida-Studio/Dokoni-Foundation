# DataDistribution Developer Boundary

DataDistribution is accepted as the fourth initial Foundation module, but its
public API and Swift target are intentionally not yet defined.

## Responsibility

DataDistribution will coordinate movement of settings and user data beyond one
local installation. It must distinguish:

- synchronization across devices owned by the same user;
- provider-backed distribution;
- explicit sharing with another person;
- explicit family sharing.

## Required concepts

An implementation must model ownership, consent, permissions, revocation,
provenance, conflicts, and recovery. It must not infer that device
synchronization grants person or family access.

## Expected dependencies

DataDistribution may:

- use Settings for configuration and settings semantics;
- ask ResourceAccess to open provider resources;
- ask DataStorage to perform storage operations.

It must not duplicate resource connectors, storage operations, or settings
decoding.

## Admission gate

Before adding Sources or a package target:

1. identify at least two concrete consumers;
2. create the ODTS hierarchy;
3. define data ownership and authorization cases;
4. define conflict and revocation behavior;
5. describe encryption and credential boundaries;
6. create API skeletons, documentation, and tests before full implementation.

This page is a boundary document, not a speculative API design.
