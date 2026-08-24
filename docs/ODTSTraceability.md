# ODTS Traceability

Dokoni Foundation uses ODTS 1.9.5.

## Required hierarchy

~~~text
ODTS EPIC
└── ODTS ITEM
    └── ODTS TASK
~~~

An Item has exactly one parent Epic. A Task has exactly one parent Item. GitHub
native issue types and native parent relationships are authoritative; text
links in bodies and source files are additional traceability.

## Code-near convention

Every source or test file materially changed by an ODTS Task begins with:

~~~swift
// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/<number>
~~~

The comment is deliberately non-executable. It must never alter imports,
runtime behavior, package products, or error handling.

Public symbol documentation may also link the Task when the symbol's contract
was introduced or substantially changed by that Task.

## Documentation convention

Every developer-guide article created by a Task links the Task near its
introduction. Module landing pages list the active documentation Task in their
introduction or Topics section.

## Test convention

Tests created or materially changed by a Task use the same file-header comment.
Test names continue to describe behavior; ODTS identifiers must not replace
behavioral names.

## Current documentation hierarchy

- ODTS EPIC [#2](https://github.com/Nijida-Studio/Dokoni-Foundation/issues/2):
  establish Foundation as a documented reusable platform.
- ODTS ITEM [#3](https://github.com/Nijida-Studio/Dokoni-Foundation/issues/3):
  provide a developer handbook and generated API reference.
- ODTS TASK [#4](https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4):
  build the DocC handbook and complete public API documentation.

## Completion checklist

- The Issue retains its creation-time ODTS Version.
- Native issue types and parent relationships are set.
- Code and tests link the implementing Task.
- Documentation matches implemented behavior.
- Tests exist or the Task records a justified alternative.
- Follow-up work is represented by a separate ODTS Task.
- The Task records validation evidence before closure.
