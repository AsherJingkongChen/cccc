FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    bubblewrap build-essential cmake curl espeak-ng exiftool \
    fd-find ffmpeg file gh git imagemagick jq libxml2-utils \
    ninja-build nodejs npm pandoc ripgrep \
    socat strace tree unzip vim wget xmlstarlet zip zsh ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN userdel -r ubuntu 2>/dev/null || true && \
    useradd -m -s /bin/zsh agent && \
    for b in chfn chsh login newgrp passwd su sudo; do rm -f /bin/$b /usr/bin/$b; done
COPY sandbox-lite.c /tmp/sandbox-lite.c
RUN gcc -Os -s -o /usr/bin/sandbox-lite /tmp/sandbox-lite.c && \
    chmod u+s /usr/bin/sandbox-lite && \
    rm /tmp/sandbox-lite.c
COPY --chmod=755 bwrap.sh /usr/bin/bwrap

USER agent
RUN curl -fsSL https://astral.sh/uv/install.sh | bash && \
    ~/.local/bin/uv python install 3.12
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN curl -fsSL https://bun.sh/install | bash
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN for pkg in gdown ruff srt yq; do ~/.local/bin/uv tool install "$pkg"; done
RUN ~/.bun/bin/bun install -g @mermaid-js/mermaid-cli mermaid-filter prettier
ENV PATH="/home/agent/.bun/bin:/home/agent/.local/bin:/home/agent/.cargo/bin:${PATH}" \
    TZ="Asia/Taipei"
COPY --chown=agent:agent .claude /home/agent/.claude
COPY --chown=agent:agent .claude.json /home/agent/.claude.json
COPY --chown=agent:agent work /home/agent/work

RUN mkdir -p /home/agent/work && \
    for f in .bash_profile .gitconfig .gitmodules .idea .ripgreprc .vscode .zprofile; do touch /home/agent/$f; done && \
    echo '{}' > /home/agent/.mcp.json
RUN claude update
WORKDIR /home/agent
ENTRYPOINT ["claude", "--channels", "plugin:discord@claude-plugins-official"]
