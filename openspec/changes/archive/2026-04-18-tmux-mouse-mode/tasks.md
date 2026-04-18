## 1. Add config file to repo

- [x] 1.1 Create `config/tmux.conf` at the repo root containing `set -g mouse on`

## 2. Update Dockerfile

- [x] 2.1 Add `COPY config/tmux.conf /home/dev/.tmux.conf` in the `USER dev` section of the Dockerfile

## 3. Verify

- [x] 3.1 Build the image (`docker build -t dev-container .`) and confirm it succeeds
- [x] 3.2 Start a fresh container and verify mouse mode is active in a new tmux session
