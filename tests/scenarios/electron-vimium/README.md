# Test Purpose

This test verifies that the patched Vimium extension works inside Electron:
+ `electron-vimium-shim` (a flake check) runs `electron_shim.js` in Node against a fake `chrome` object: storage area mapping, `onChanged` area names, callbacks, session clearing, API stubs, idempotency
+ `ciTests.electron-vimium` (CI only, never run locally) boots a VM with X11, starts nixpkgs `electron` with `inject.cjs`, and asserts `f` renders link hints and `j` scrolls the page
