# Dev Container — Ubuntu 24.04
# Tools: Node.js LTS, Python (pyenv), Java/Maven/Gradle (sdkman), Rust (rustup),
#        .NET SDK 10.0, Godot 4.6.2 (.NET build, headless),
#        Angular CLI, GitHub CLI, Docker-in-Docker, Azure CLI,
#        kubectl, Terraform, Claude Code (user-install), zsh + tmux + oh-my-zsh + Powerlevel10k
#
# Build: docker build -t dev-container .
# Use:   spin.sh <project-name>

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# ── 1. Base packages ──────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    sudo \
    git \
    zsh \
    tmux \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    jq \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Rename built-in ubuntu user (UID 1000) to dev ────────────────────────
# Ubuntu 24.04 ships with an 'ubuntu' user at UID 1000; rename it instead of
# creating a new one to avoid a UID conflict.
RUN usermod -l dev -d /home/dev -m ubuntu \
    && groupmod -n dev ubuntu \
    && usermod -s /usr/bin/zsh dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ── 3. Docker CE ──────────────────────────────────────────────────────────────
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
       | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
       https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
       > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y \
       docker-ce \
       docker-ce-cli \
       containerd.io \
       docker-buildx-plugin \
       docker-compose-plugin \
    && usermod -aG docker dev \
    && rm -rf /var/lib/apt/lists/*

# ── 4. GitHub CLI ─────────────────────────────────────────────────────────────
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
       https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ── 5. Node.js LTS (via NodeSource) ──────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ── 6. Angular CLI + Claude Code + OpenSpec + LSP servers (global npm) ───────
RUN npm install -g @angular/cli @fission-ai/openspec \
    typescript typescript-language-server pyright

# ── 7. Azure CLI ──────────────────────────────────────────────────────────────
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && rm -rf /var/lib/apt/lists/*

# ── 8. kubectl ────────────────────────────────────────────────────────────────
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
       | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
       https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
       > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl \
    && rm -rf /var/lib/apt/lists/*

# ── 9. Terraform ──────────────────────────────────────────────────────────────
RUN wget -O- https://apt.releases.hashicorp.com/gpg \
       | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
       https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
       > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y terraform \
    && rm -rf /var/lib/apt/lists/*

# ── 10. .NET SDK 10.0 ────────────────────────────────────────────────────────
RUN curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb \
       -o /tmp/packages-microsoft-prod.deb \
    && dpkg -i /tmp/packages-microsoft-prod.deb \
    && rm /tmp/packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-10.0 \
    && rm -rf /var/lib/apt/lists/*

# ── 11. Godot 4.6.2 (.NET build, linux/arm64) ────────────────────────────────
ENV GODOT_BIN=/usr/local/bin/godot

RUN mkdir -p /opt/godot \
    && curl -fsSL -o /tmp/godot.zip \
         "https://github.com/godotengine/godot-builds/releases/download/4.6.2-stable/Godot_v4.6.2-stable_mono_linux_arm64.zip" \
    && unzip /tmp/godot.zip -d /tmp/godot_extract \
    && mv /tmp/godot_extract/Godot_v4.6.2-stable_mono_linux_arm64/Godot_v4.6.2-stable_mono_linux.arm64 \
          /opt/godot/godot \
    && mv /tmp/godot_extract/Godot_v4.6.2-stable_mono_linux_arm64/GodotSharp \
          /opt/godot/GodotSharp \
    && chmod +x /opt/godot/godot \
    && ln -s /opt/godot/godot /usr/local/bin/godot \
    && rm -rf /tmp/godot.zip /tmp/godot_extract

# ── 13. rust-analyzer (LSP) ──────────────────────────────────────────────────
RUN ARCH=$(uname -m) \
    && case "${ARCH}" in \
         x86_64)  RA_TARGET="x86_64-unknown-linux-gnu" ;; \
         aarch64) RA_TARGET="aarch64-unknown-linux-gnu" ;; \
         *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
       esac \
    && curl -L -o /tmp/rust-analyzer.gz \
         "https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-${RA_TARGET}.gz" \
    && gunzip /tmp/rust-analyzer.gz \
    && mv /tmp/rust-analyzer /usr/local/bin/rust-analyzer \
    && chmod +x /usr/local/bin/rust-analyzer

# ── 14. eclipse.jdt.ls (Java LSP) ────────────────────────────────────────────
RUN mkdir -p /opt/jdtls \
    && JDTLS_VER=$(curl -fsSL "https://download.eclipse.org/jdtls/milestones/?d" \
          | grep -o "href='/jdtls/milestones/[0-9][^']*'" \
          | sed "s|href='/jdtls/milestones/||;s|'||g" \
          | sort -V | tail -1) \
    && JDTLS_FILE=$(curl -fsSL "https://download.eclipse.org/jdtls/milestones/${JDTLS_VER}/latest.txt" | tr -d '[:space:]') \
    && curl -fsSL -o /tmp/jdtls.tar.gz \
          "https://download.eclipse.org/jdtls/milestones/${JDTLS_VER}/${JDTLS_FILE}" \
    && tar -xzf /tmp/jdtls.tar.gz -C /opt/jdtls \
    && rm /tmp/jdtls.tar.gz

RUN printf '#!/usr/bin/env bash\n\
JAVA_HOME=/home/dev/.sdkman/candidates/java/current\n\
exec "${JAVA_HOME}/bin/java" \\\n\
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \\\n\
  -Dosgi.bundles.defaultStartLevel=4 \\\n\
  -Declipse.product=org.eclipse.jdt.ls.core.product \\\n\
  -Dlog.level=ALL \\\n\
  -noverify \\\n\
  -Xmx1G \\\n\
  --add-modules=ALL-SYSTEM \\\n\
  --add-opens java.base/java.util=ALL-UNNAMED \\\n\
  --add-opens java.base/java.lang=ALL-UNNAMED \\\n\
  -jar /opt/jdtls/plugins/org.eclipse.equinox.launcher_*.jar \\\n\
  -configuration "${HOME}/.local/share/jdtls/config_linux" \\\n\
  -data "${1:-${HOME}/jdtls-workspace}" \\\n\
  "$@"\n' > /usr/local/bin/jdtls \
    && chmod +x /usr/local/bin/jdtls

# ── Switch to dev user for user-specific tools ───────────────────────────────
USER dev
WORKDIR /home/dev

# ── 15. jdtls user config (writable copy of /opt/jdtls/config_linux) ─────────
RUN mkdir -p "${HOME}/.local/share/jdtls" \
    && cp -r /opt/jdtls/config_linux "${HOME}/.local/share/jdtls/config_linux"

# ── 16. Claude Code (user-owned npm prefix, enables auto-update) ─────────────
# Installed separately from the root npm globals so the dev user can write to
# the prefix and Claude Code's auto-update mechanism works without sudo.
RUN npm config set prefix "${HOME}/.npm-global" \
    && npm install -g @anthropic-ai/claude-code \
    && echo '' >> "${HOME}/.zshrc" \
    && echo '# Claude Code (user-local npm prefix)' >> "${HOME}/.zshrc" \
    && echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "${HOME}/.zshrc"

# ── 17. oh-my-zsh + Powerlevel10k + plugins ──────────────────────────────────
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
       "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions \
       "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting \
       "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
    && sed -i 's|ZSH_THEME="robbyrussell"|ZSH_THEME="powerlevel10k/powerlevel10k"|' "${HOME}/.zshrc" \
    && sed -i 's|plugins=(git)|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|' "${HOME}/.zshrc"

# ── 18. pyenv + Python 3.12 ───────────────────────────────────────────────────
ENV PYENV_ROOT="/home/dev/.pyenv"
ENV PATH="${PYENV_ROOT}/bin:${PATH}"

RUN curl https://pyenv.run | bash \
    && echo '' >> "${HOME}/.zshrc" \
    && echo '# pyenv' >> "${HOME}/.zshrc" \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "${HOME}/.zshrc" \
    && echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "${HOME}/.zshrc" \
    && echo 'eval "$(pyenv init -)"' >> "${HOME}/.zshrc"

RUN eval "$(${PYENV_ROOT}/bin/pyenv init -)" \
    && pyenv install 3.12 \
    && pyenv global 3.12

# ── 19. gdtoolkit (GDScript linter/formatter) ────────────────────────────────
RUN eval "$(${PYENV_ROOT}/bin/pyenv init -)" \
    && pip install gdtoolkit

# ── 20. SDKMAN + Java (Temurin 21 LTS) + Maven + Gradle ──────────────────────
ENV SDKMAN_DIR="/home/dev/.sdkman"

RUN curl -s "https://get.sdkman.io" | bash \
    && echo '' >> "${HOME}/.zshrc" \
    && echo '# sdkman' >> "${HOME}/.zshrc" \
    && echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> "${HOME}/.zshrc" \
    && echo '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"' >> "${HOME}/.zshrc"

RUN bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh \
    && sdk install java 21.0.5-tem \
    && sdk install maven \
    && sdk install gradle \
    && sdk flush archives"

# ── 21. Rust (via rustup) ─────────────────────────────────────────────────────
ENV CARGO_HOME="/home/dev/.cargo"
ENV RUSTUP_HOME="/home/dev/.rustup"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path \
    && echo '' >> "${HOME}/.zshrc" \
    && echo '# Rust / cargo' >> "${HOME}/.zshrc" \
    && echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "${HOME}/.zshrc"

RUN "${CARGO_HOME}/bin/cargo" install cargo-watch cargo-edit

# ── 22. csharp-ls (C# LSP server) ────────────────────────────────────────────
RUN dotnet tool install -g csharp-ls \
    && echo '' >> "${HOME}/.zshrc" \
    && echo '# .NET global tools' >> "${HOME}/.zshrc" \
    && echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> "${HOME}/.zshrc"

# ── 23. Docker alias for DinD convenience ────────────────────────────────────
RUN echo '' >> "${HOME}/.zshrc" \
    && echo '# Start Docker daemon when needed (DinD)' >> "${HOME}/.zshrc" \
    && echo '# Uses vfs storage driver — required for nested containers on OrbStack/macOS' >> "${HOME}/.zshrc" \
    && echo 'alias start-docker="sudo dockerd --storage-driver=vfs > /tmp/dockerd.log 2>&1 & sleep 3 && echo Docker daemon started"' >> "${HOME}/.zshrc"

# ── 24. tmux config + Catppuccin theme ───────────────────────────────────────
# Use tmux-256color inside sessions (256-colour + true-colour passthrough).
# Note: Powerline/Nerd Font glyph rendering in tmux requires LANG to contain
# "UTF-8" so tmux enables UTF-8 mode — set via ENV LANG=C.UTF-8 above.
RUN git clone -b v2.1.3 https://github.com/catppuccin/tmux.git \
       "${HOME}/.tmux/plugins/catppuccin/tmux"

RUN printf '%s\n' \
    'set -g default-terminal "tmux-256color"' \
    'set -ga terminal-overrides ",xterm*:Tc"' \
    '' \
    '# Catppuccin theme (Mocha)' \
    'set -g @catppuccin_flavor "mocha"' \
    'set -g @catppuccin_window_status_style "rounded"' \
    'run ~/.tmux/plugins/catppuccin/tmux/catppuccin.tmux' \
    '' \
    '# Status bar' \
    'set -g status-right-length 100' \
    'set -g status-left-length 100' \
    'set -g status-left ""' \
    'set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}"' \
    > "${HOME}/.tmux.conf"

# ── 25. Final setup ───────────────────────────────────────────────────────────
WORKDIR /home/dev/workspace

CMD ["zsh"]
