# Jolt Physics bindings for Odin

Includes a vendored version of JoltC, which is the source of truth for the Odin bindings.

Native artifacts use the same platform layout as the other vendor bindings:

- `windows_x64/` and `windows_arm64/` contain `joltc.dll`, its import library, and `joltc_static.lib`.
- `darwin_x64/` and `darwin_arm64/` contain `libjoltc.dylib` and `joltc.darwin.a`.
- `linux_x64/` and `linux_arm64/` contain `libjoltc.so` and `joltc.linux.a`.

`build.sh` and `build.bat` build shared JoltC. `build_static.sh` and `build_static.bat` build static JoltC.
