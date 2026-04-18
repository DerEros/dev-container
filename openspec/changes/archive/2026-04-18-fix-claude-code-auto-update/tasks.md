## 1. Dockerfile — Root Install Step

- [x] 1.1 Remove `@anthropic-ai/claude-code` from the `npm install -g` command in step 6

## 2. Dockerfile — User Install Step

- [x] 2.1 After `USER dev`, add a step that sets the user npm prefix: `npm config set prefix ~/.npm-global`
- [x] 2.2 Install Claude Code as the `dev` user: `npm install -g @anthropic-ai/claude-code`
- [x] 2.3 Append `export PATH="$HOME/.npm-global/bin:$PATH"` to `~/.zshrc` in the same step, before other PATH entries so `claude` resolves to the user install

## 3. Verify

- [x] 3.1 Build the container image and confirm it builds successfully
- [x] 3.2 Run the container and verify `which claude` returns `/home/dev/.npm-global/bin/claude`
- [x] 3.3 Run the container and verify `npm config get prefix` returns `/home/dev/.npm-global`
- [x] 3.4 Confirm `claude` launches without auto-update permission errors
