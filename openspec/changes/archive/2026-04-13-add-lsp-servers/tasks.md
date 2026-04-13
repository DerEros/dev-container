## 1. npm LSP servers (TypeScript + Python)

- [x] 1.1 Add `typescript`, `typescript-language-server`, and `pyright` to the `npm install -g` line in the Dockerfile

## 2. rust-analyzer

- [x] 2.1 Add a Dockerfile `RUN` step to download the `rust-analyzer-x86_64-unknown-linux-gnu.gz` binary from the latest GitHub release, decompress it, and install it to `/usr/local/bin/rust-analyzer`

## 3. eclipse.jdt.ls

- [x] 3.1 Add a Dockerfile `RUN` step to download the latest `eclipse.jdt.ls` milestone tarball and extract it to `/opt/jdtls`
- [x] 3.2 Add a `jdtls` wrapper script at `/usr/local/bin/jdtls` that invokes the JDT launcher jar with the correct `JAVA_HOME` and a default data directory

## 4. Specs

- [x] 4.1 Merge the `lsp-servers` and `dev-container-image` delta specs into `openspec/specs/`

## 5. Verification

- [x] 5.1 Rebuild the container image and verify `typescript-language-server --version`, `pyright --version`, `rust-analyzer --version`, and `jdtls` all run without error as the `dev` user
