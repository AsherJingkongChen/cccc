FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    bubblewrap build-essential cmake curl espeak-ng exiftool \
    fd-find ffmpeg file gh git imagemagick jq libxml2-utils \
    ninja-build nodejs npm pandoc ripgrep \
    socat tree unzip vim wget xmlstarlet zip zsh ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN userdel -r ubuntu 2>/dev/null || true && \
    useradd -m -s /bin/zsh agent && \
    for b in chfn chsh login newgrp passwd su sudo; do rm -f /bin/$b /usr/bin/$b; done
COPY bwrap.sh /usr/bin/bwrap.sh
RUN mv /usr/bin/bwrap /usr/bin/bwrap.real && \
    chmod u+s /usr/bin/bwrap.real && \
    ln -s /usr/bin/bwrap.sh /usr/bin/bwrap && \
    chmod 755 /usr/bin/bwrap.sh
USER agent
RUN curl -fsSL https://astral.sh/uv/install.sh | bash && \
    ~/.local/bin/uv python install 3.12
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN curl -fsSL https://bun.sh/install | bash
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN for pkg in gdown ruff srt yq; do ~/.local/bin/uv tool install "$pkg"; done
RUN ~/.bun/bin/bun install -g @mermaid-js/mermaid-cli mermaid-filter prettier
ENV PATH="/home/agent/.bun/bin:/home/agent/.local/bin:/home/agent/.cargo/bin:${PATH}"
COPY --chown=agent:agent .claude /home/agent/.claude
COPY --chown=agent:agent .claude.json /home/agent/.claude.json
RUN mkdir -p /home/agent/work && \
    for f in .bash_profile .gitconfig .gitmodules .idea .ripgreprc .vscode .zprofile; do touch /home/agent/$f; done && \
    echo '{}' > /home/agent/.mcp.json
WORKDIR /home/agent
ENTRYPOINT ["claude", "--channels", "plugin:discord@claude-plugins-official"]
