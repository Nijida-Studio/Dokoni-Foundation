# LocalSettings Store

This directory will contain the settings store.

The store uses DataStorage to read opaque data, decodes it as settings, applies
changes, encodes the result, and writes it back through DataStorage.
