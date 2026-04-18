## 1. Add config file to repo

- [x] 1.1 Create `config/` directory at the repo root
- [x] 1.2 Copy `~/.p10k.zsh` from the host into the repo as `config/p10k.zsh`

## 2. Update Dockerfile

- [x] 2.1 Add `COPY config/p10k.zsh /home/dev/.p10k.zsh` after step 17 (oh-my-zsh + p10k install), within the `USER dev` section

## 3. Verify

- [x] 3.1 Build the image (`docker build -t dev-container .`) and confirm it succeeds
- [x] 3.2 Start a fresh container and verify the p10k wizard does NOT appear and the prompt renders correctly
