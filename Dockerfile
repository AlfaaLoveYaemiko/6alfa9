FROM --platform=$TARGETOS/$TARGETARCH python:3.13-slim-bookworm

LABEL org.opencontainers.image.title="6alfa9"
LABEL org.opencontainers.image.description="Pterodactyl-compatible yolk: Python 3.13 + Chromium + ChromeDriver + Xvfb + Selenium runtime libs."
LABEL org.opencontainers.image.licenses="MIT"

# --- 1. Browser + Xvfb + runtime libs (verbatim from user's spec) ---------
# Plus tini/git/gcc/g++ for Python projects that pip-build C extensions and
# for clean PID-1 signal handling.
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    curl \
    ca-certificates \
    unzip \
    xvfb \
    xauth \
    chromium \
    chromium-driver \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    git \
    gcc \
    g++ \
    tini \
    procps \
    iproute2 \
    dnsutils \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# --- 2. Pterodactyl convention: user "container" with uid 1000 ----------
RUN useradd -m -d /home/container -s /bin/bash container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Help Selenium / start.py find the browser & driver without any guessing.
ENV CHROME_BIN=/usr/bin/chromium \
    CHROME_BINARY=/usr/bin/chromium \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver \
    SE_CHROMEDRIVER=/usr/bin/chromedriver \
    SE_OFFLINE=true \
    PATH=/home/container/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

STOPSIGNAL SIGINT

COPY --chown=container:container entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]
