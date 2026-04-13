## 1. .NET SDK 10.0

- [x] 1.1 Add Microsoft apt feed and GPG key (root layer, before existing apt installs)
- [x] 1.2 Install `dotnet-sdk-10.0` via apt
- [x] 1.3 Verify `dotnet --version` outputs `10.x` in a build test

## 2. Godot 4.6.2 .NET Binary

- [x] 2.1 Add `ENV GODOT_BIN=/usr/local/bin/godot` to the Dockerfile
- [x] 2.2 Download `Godot_v4.6.2-stable_mono_linux_arm64.zip` from godot-builds GitHub releases, extract, and install binary to `/usr/local/bin/godot` (root layer)
- [x] 2.3 Verify `godot --version` prints `4.6.2.stable.mono` and `godot --headless --quit` exits 0

## 3. C# LSP (csharp-ls)

- [x] 3.1 Install `csharp-ls` as a dotnet global tool for the `dev` user (`dotnet tool install -g csharp-ls`)
- [x] 3.2 Add `$HOME/.dotnet/tools` to PATH in `.zshrc`
- [x] 3.3 Verify `csharp-ls --version` is available in the dev user's shell

## 4. GDScript Tooling (gdtoolkit)

- [x] 4.1 Install `gdtoolkit` via pip using the pyenv-managed Python (`pip install gdtoolkit`), as the `dev` user
- [x] 4.2 Verify `gdlint --version` and `gdformat --version` are available in the dev user's shell

## 5. Dockerfile Hygiene

- [x] 5.1 Update the top comment block in the Dockerfile to list Godot and .NET SDK among the installed tools
- [x] 5.2 Ensure `rm -rf /var/lib/apt/lists/*` is included after apt installs to keep image size minimal
