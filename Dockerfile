# Dev Container — Ubuntu 24.04
# Tools: Node.js LTS, Python (pyenv), Java/Maven/Gradle (sdkman), Rust (rustup),
#        Angular CLI, GitHub CLI, Docker-in-Docker, Azure CLI,
#        kubectl, Terraform, Claude Code, zsh + tmux + oh-my-zsh + Powerlevel10k
#
# Build: docker build -t dev-container .
# Use:   spin.sh <project-name>

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

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

# ── 6. Angular CLI + Claude Code (global npm) ────────────────────────────────
RUN npm install -g @angular/cli @anthropic-ai/claude-code

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

# ── Switch to dev user for user-specific tools ───────────────────────────────
USER dev
WORKDIR /home/dev

# ── 10. oh-my-zsh + Powerlevel10k + plugins ──────────────────────────────────
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
       "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions \
       "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting \
       "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
    && sed -i 's|ZSH_THEME="robbyrussell"|ZSH_THEME="powerlevel10k/powerlevel10k"|' "${HOME}/.zshrc" \
    && sed -i 's|plugins=(git)|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|' "${HOME}/.zshrc"

# ── 11. pyenv + Python 3.12 ───────────────────────────────────────────────────
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

# ── 12. SDKMAN + Java (Temurin 21 LTS) + Maven + Gradle ──────────────────────
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

# ── 13. Rust (via rustup) ─────────────────────────────────────────────────────
ENV CARGO_HOME="/home/dev/.cargo"
ENV RUSTUP_HOME="/home/dev/.rustup"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path \
    && echo '' >> "${HOME}/.zshrc" \
    && echo '# Rust / cargo' >> "${HOME}/.zshrc" \
    && echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "${HOME}/.zshrc"

RUN "${CARGO_HOME}/bin/cargo" install cargo-watch cargo-edit

# ── 14. Docker alias for DinD convenience ────────────────────────────────────
RUN echo '' >> "${HOME}/.zshrc" \
    && echo '# Start Docker daemon when needed (DinD)' >> "${HOME}/.zshrc" \
    && echo '# Uses vfs storage driver — required for nested containers on OrbStack/macOS' >> "${HOME}/.zshrc" \
    && echo 'alias start-docker="sudo dockerd --storage-driver=vfs > /tmp/dockerd.log 2>&1 & sleep 3 && echo Docker daemon started"' >> "${HOME}/.zshrc"

# ── 15. Final setup ───────────────────────────────────────────────────────────
WORKDIR /home/dev/workspace

CMD ["zsh"]
