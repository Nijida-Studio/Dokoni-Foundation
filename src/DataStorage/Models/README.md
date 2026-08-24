# DataStorage Models

The first byte-stream slice needs no DataStorage-owned location model:
ResourceAccess owns resource requests and connections.

Models will be added only when a storage operation needs them. Application
content formats remain deliberately outside DataStorage.
