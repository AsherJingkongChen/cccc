FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu24.04

RUN sed -i 's/archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's/security.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash bubblewrap build-essential cmake curl espeak-ng exiftool \
    fd-find ffmpeg file gh git imagemagick jq libxml2-utils \
    ninja-build nodejs npm pandoc ripgrep \
    socat strace tree unzip vim wget xmlstarlet zip zsh ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN userdel -r ubuntu 2>/dev/null || true && \
    useradd -m -s /bin/zsh agent && \
    for b in chfn chsh login newgrp passwd su sudo; do rm -f /bin/$b /usr/bin/$b; done
COPY sandbox-lite.c /tmp/sandbox-lite.c
COPY sandbox-lite-port-ban.c /tmp/sandbox-lite-port-ban.c
RUN gcc -Os -s -o /usr/bin/sandbox-lite /tmp/sandbox-lite.c && \
    gcc -Os -s -o /usr/local/lib/sandbox-lite-port-ban.so /tmp/sandbox-lite-port-ban.c -shared -fPIC -ldl && \
    chmod 4755 /usr/bin/sandbox-lite && \
    rm /tmp/sandbox-lite.c /tmp/sandbox-lite-port-ban.c
COPY --chmod=755 bwrap.sh /usr/bin/bwrap

USER agent
RUN curl -fsSL https://astral.sh/uv/install.sh | bash
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN curl -fsSL https://bun.sh/install | bash
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/agent/.bun/bin:/home/agent/.local/bin:/home/agent/.cargo/bin:${PATH}" \
    TZ="Asia/Taipei"
RUN uv python install 3.12
RUN for pkg in litellm[proxy] gdown ruff srt yq; do uv tool install "$pkg"; done
RUN bun install -g @mermaid-js/mermaid-cli mermaid-filter prettier
RUN claude update

WORKDIR /home/agent
COPY --chown=agent:agent .claude /home/agent/.claude
COPY --chown=agent:agent .claude.json /home/agent/.claude.json
COPY --chown=agent:agent .entrypoint.sh /home/agent/.entrypoint.sh
COPY --chown=agent:agent work /home/agent/work

RUN echo '{}' > .mcp.json
RUN touch .bash_profile .gitconfig .gitmodules .idea .ripgreprc .vscode .zprofile

ENTRYPOINT ["./.entrypoint.sh"]
